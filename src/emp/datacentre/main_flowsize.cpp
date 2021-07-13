#include "config.h"
#include <sstream>
#include <strstream>
#include <iostream>
#include <string.h>
#include <list>
#include <math.h>
#include "network.h"
#include "randomqueue.h"
#include "pipe.h"
#include "eventlist.h"
#include "logfile.h"
#include "loggers.h"
#include "clock.h"
#include "tcp.h"
#include "dctcp.h"
#include "topology.h"
#include "connection_matrix.h"

#include "main.h"

// TOPOLOGY TO USE
#if CHOSEN_TOPO == FAT
#include "fat_tree_topology.h"
#elif CHOSEN_TOPO == LEAFSPINE
#include "leaf_spine_topology.h"
#elif CHOSEN_TOPO == RRG
#include "rand_regular_topology.h"
#endif

// Simulation params
#define PRINT_PATHS 0
#define PERIODIC 0

// Parameters for average flow size experiments
#define LARGE_FLOWSIZE false
#define FLOWSIZE_MULT 0

uint32_t RTT = 2; // us
int ssthresh = 43; //65 KB
int N = NSW;

unsigned int subflow_count = 1;

string ntoa(double n);
string itoa(uint64_t n);

//#define SWITCH_BUFFER (SERVICE * RTT / 1000)

const double SIMTIME = 101;

EventList eventlist;

Logfile* lg;

uint64_t total_path_lengths = 0;
uint64_t total_available_paths = 0;
uint64_t total_available_first_hops = 0;
// extern uint64_t total_packet_bytes;

void exit_error(char* progr) {
    cout << "Usage " << progr << " [UNCOUPLED(DEFAULT)|COUPLED_INC|FULLY_COUPLED|COUPLED_EPSILON] [epsilon][COUPLED_SCALABLE_TCP" << endl;
    exit(1);
}

void print_path(std::ofstream &paths,route_t* rt){
  for (unsigned int i=1;i<rt->size()-1;i+=2){
    RandomQueue* q = (RandomQueue*)rt->at(i);
    if (q!=NULL)
      paths << q->str() << " ";
    else 
      paths << "NULL ";
  }
  paths<<endl;
}

int main(int argc, char **argv) {
    eventlist.setEndtime(timeFromSec(SIMTIME));
    Clock c(timeFromSec(50 / 100.), eventlist);
    int algo = COUPLED_EPSILON;
    double epsilon = 1;
    int param, paramo = 0;
    int multiplier, korn = 0;
    string paramstring, paramstringo;
    string multiplierstring, kornstring;
    stringstream filename(ios_base::out);
    string rfile;
    string partitionsfile;
    string conn_matrix;
    string routing;
    if (argc > 1) {
      int i = 1;
      if (!strcmp(argv[1],"-o")){
          filename << argv[2];
          i+=2;
      }
      else
          filename << "logout.dat";

      if (argc>i&&!strcmp(argv[i],"-sub")){
          subflow_count = atoi(argv[i+1]);
          i+=2;
      }

      if (argc>i&&!strcmp(argv[i],"-TMatrix")){
          conn_matrix = argv[i+1];
          i+=2;
      }
      cout << "Using Connection Matrix: "<<conn_matrix<<endl;

      if (argc>i&&!strcmp(argv[i],"-mult")){
          multiplierstring = argv[i+1];
          multiplier = atoi(argv[i+1]);
          i+=2;
      }
      cout << "Multiplier=" << multiplier << endl;

      if (argc>i&&!strcmp(argv[i],"-r")){
          routing = argv[i+1];
          i+=2;
      }
      cout << "Using Routing: "<<routing<<endl;
      
      if (argc>i&&!strcmp(argv[i],"-k")){
          kornstring = argv[i+1];
          korn = atoi(argv[i+1]);
          i+=2;
      }
      cout << "k or n = " << korn << endl;     

      if (argc>i&&!strcmp(argv[i],"-param")){
          paramstring = argv[i+1];
          param = atoi(argv[i+1]);
          i+=2;
      }
      cout << "Using subflow count " << subflow_count <<endl;

      if (argc>i&&!strcmp(argv[i],"-paramo")){
          paramstringo = argv[i+1];
          paramo = atoi(argv[i+1]);
          i+=2;
      }
      cout << "Using paramo " << paramo <<endl;

      if (argc>i&&!strcmp(argv[i],"-topo")){
          rfile = argv[i+1];
          i+=2;
      }
      cout << "Topology File: " << rfile << endl;

      int seed=240;
      if (argc>i&&!strcmp(argv[i],"-seed")){
          seed = atoi(argv[i+1]);
          srand(seed);
          i+=2;
      }
      cout << "Using seed: " << seed << endl;

      if (argc>i&&!strcmp(argv[i],"-partitions")){
          partitionsfile = argv[i+1];
          i+=2;
      }
      cout << "Partitions File: " << partitionsfile << endl;

      if (argc>i){
          exit_error(argv[0]);
      }
    }
    srand(time(NULL));

    cout <<  "Using algo="<<algo<< " epsilon=" << epsilon << endl;
    // prepare the loggers

    cout << "Logging to " << filename.str() << endl;
    //Logfile 
    Logfile logfile(filename.str(), eventlist);

#if PRINT_PATHS
    filename << ".paths";
    cout << "Logging path choices to " << filename.str() << endl;
    std::ofstream paths(filename.str().c_str());
    if (!paths){
      cout << "Can't open for writing paths file!"<<endl;
      exit(1);
    }
#endif

    lg = &logfile;

    logfile.setStartTime(timeFromSec(0));

    int logger_period_ms = 1000000;
    TcpSinkLoggerSampling sinkLogger = TcpSinkLoggerSampling(timeFromMs(logger_period_ms), eventlist);
    logfile.addLogger(sinkLogger);

    TcpLoggerSimple logTcp;logfile.addLogger(logTcp);

    TcpSrc* tcpSrc;
    TcpSink* tcpSnk;
    route_t* routeout, *routein;
    TcpRtxTimerScanner tcpRtxScanner(timeFromMs(10), eventlist);

#ifdef FAT_TREE
    FatTreeTopology* top = new FatTreeTopology(&logfile, &eventlist, RANDOM);
#endif

#ifdef LEAF_SPINE
    LeafSpineTopology* top = new LeafSpineTopology(&logfile, &eventlist, RANDOM);
#endif

//< Ankit added
#ifdef RAND_REGULAR
    //= "../../../rand_topologies/rand_" + ntoa(NSW) + "_" + ntoa(R) + ".txt";
    RandRegularTopology* top = new RandRegularTopology(&logfile, &eventlist, rfile, RANDOM, routing, korn);
#endif
//>

    vector<route_t*>*** net_paths;
    net_paths = new vector<route_t*>**[NHOST];
    for (int i=0;i<NHOST;i++){
       net_paths[i] = new vector<route_t*>*[NHOST];
       for (int j = 0;j<NHOST;j++){
          net_paths[i][j] = NULL;
       }
    }

    // Permutation connections
    ConnectionMatrix* conns = new ConnectionMatrix(NHOST);
    //conns->setLocalTraffic(top);
    
    //cout<< "Running sampled A2A with sample rate: "<< (double)param/8000.0 <<endl;
    assert (conn_matrix == "FILE" or conn_matrix == "FEW_TO_SOME" or conn_matrix == "RANDOM" or conn_matrix == "RACK_TO_RACK");
    if(conn_matrix == "PERM")
        conns->setPermutation();
    else if(conn_matrix == "SAMPLED_PERM"){
        cout << "Running perm with " << param << " connections" << endl;
        conns->setPermutation(param);
    }
    else if(conn_matrix == "HOT_SPOT"){
        conns->setHotspot(param,N/param);
    }
    else if(conn_matrix == "MANY_TO_MANY"){
        conns->setManytoMany(param);
    }
    else if(conn_matrix == "ALL_TO_ALL"){
        conns->setAlltoAll(top);
    }
    else if(conn_matrix == "RACK_TO_RACK"){
        conns->setRacktoRackFlows(top, param, paramo, multiplier);
    }
    else if(conn_matrix == "FEW_TO_SOME"){
        conns->setFewtoSomeFlows(top, param, paramo, multiplier);
    }
    else if(conn_matrix == "UNIFORM"){
        conns->setUniform(param);
    }
    else if(conn_matrix == "RANDOM"){
        int connxs = (NHOST * NHOST * param)/1000;
        conns->setRandomFlows(connxs);
    }
    else if(conn_matrix == "FILE"){
        conns->setFlowsFromFile(top, paramstring, multiplier);
    }
    else{
        cout<<"conn_matrix: "<<conn_matrix<<" not supported. Supported options are: "<<endl;
        cout<<"PERM  //Random Permutation"<<endl;
        cout<<"SAMPLED_PERM  //Sampled Random Permutation, sample ratio: param"<<endl;
        cout<<"MANY_TO_MANY  //All to all for a subset of hosts"<<endl;
        cout<<"ALL_TO_ALL  //All to all for all hosts"<<endl;
		cout<<"ALL_TO_FEW  //All to few for all hosts"<<endl;
        cout<<"FEW_TO_SOME  //Few servers to a subset of all hosts"<<endl;
        cout<<"UNIFORM  //param random flows from each host"<<endl;
        cout<<"RANDOM  //Random sources and destinations, for param percentage of pairs"<<endl;
        cout<<"FILE  //Read Traffic Matrix from file (filename = param)"<<endl;
        return 0;
    }
    map<int,vector<int>*>::iterator it;

    typedef pair<int, int> PII;
    int flowID = 0;
    for (Flow& flow: conns->flows){
        flowID++;
        if(flowID%1000==0)
            cout << "FLOW: " << flow.src << "(" << top->ConvertHostToRack(flow.src)<<") -> "
                 << flow.dst << "("<< top->ConvertHostToRack(flow.dst) << ") bytes: "
                 << flow.bytes << " start_time_ms " << flow.start_time_ms << endl;

        if (!net_paths[flow.src][flow.dst]){
            //cout << "Getting paths from topo" << endl;	
            net_paths[flow.src][flow.dst] = top->get_paths(flow.dst, flow.src).second;
        }
        if (!net_paths[flow.dst][flow.src]){
            //cout << "Getting paths from topo" << endl;	
            net_paths[flow.dst][flow.src] = top->get_paths(flow.dst, flow.src).second;
        }

        size_t num_available_paths = net_paths[flow.src][flow.dst]->size();
        total_available_paths += num_available_paths;
        // cout << "**********temporary printing***********" <<  endl;
        // route_t *temp_route0 = new route_t(*(net_paths[flow.src][flow.dst]->at(0)));
        // for (vector<PacketSink*>::const_iterator it = temp_route0->begin(); it != temp_route0->end(); ++it) {
        //     cout << (*it)->nodename() << " ";
        // }
        // cout << endl;
        // route_t *temp_route1 = new route_t(*(net_paths[flow.src][flow.dst]->at(1)));
        // for (vector<PacketSink*>::const_iterator it = temp_route1->begin(); it != temp_route1->end(); ++it) {
        //     cout << (*it)->nodename() << " ";
        // }
        // cout << endl;
        set<PacketSink *> first_hops_till_now;
        for (unsigned int i=0; i<(unsigned int)num_available_paths; i++) {
            route_t *this_route = new route_t(*(net_paths[flow.src][flow.dst]->at(i)));
            PacketSink *this_first_hop = this_route->at(3); // Queue inherits from PacketSink
            first_hops_till_now.insert(this_first_hop);
        }
        total_available_first_hops += first_hops_till_now.size();

        if (flowID%1000==1){
            cout << "How many paths? = " << net_paths[flow.src][flow.dst]->size() << endl;
            for (unsigned int k = 0; k < net_paths[flow.src][flow.dst]->size(); k++) {
                //cout << "Length of path " << k << " = "<< (net_paths[flow.src][flow.dst]->at(k)->size() - 5) / 2 << endl;
                // (net_paths[src][dest]->at(k));
                //RandomQueue* q = (RandomQueue*)rt->at(i);
            }
        }

        assert (subflow_count == 1);
        tcpSrc = new TcpSrc(NULL, NULL, eventlist);
        tcpSnk = new TcpSink();
        tcpSrc->set_ssthresh(ssthresh*Packet::data_packet_size());

        #if LARGE_FLOWSIZE
            tcpSrc->set_flowsize(flow.bytes * FLOWSIZE_MULT);
        #else
            tcpSrc->set_flowsize(flow.bytes);
        #endif

        unsigned int choice = 0;
        choice = rand()%net_paths[flow.src][flow.dst]->size();
        //cout<<choice<<" : "; print_path(cout, net_paths[src][dest]->at(choice));

        // Ankit: Which path out of available paths is chosen
        //cout << "Choice "<<choice<<" out of "<<net_paths[src][dest]->size();
        if (choice>=net_paths[flow.src][flow.dst]->size()){
            cout << "Weird path choice " << choice << " out of " << net_paths[flow.src][flow.dst]->size();
            exit(1);
        }

        #if PRINT_PATHS
                paths << "Route from "<< ntoa(src) << " to " << ntoa(dest) << "  (" << choice << ") -> " ;
                print_path(paths,net_paths[src][dest]->at(choice));
        #endif

        //last entry is path length
        tcpSrc->setName("tcp_src_" + ntoa(flow.src) + "_" + ntoa(flow.dst) + "_" + 
                        ntoa(net_paths[flow.src][flow.dst]->at(choice)->size()/2 - 2));
        logfile.writeName(*tcpSrc);

        tcpSnk->setName("tcp_sink_" + ntoa(flow.src) + "_" + ntoa(flow.dst) + "_" + 
                        ntoa(net_paths[flow.src][flow.dst]->at(choice)->size()/2 - 2));
        logfile.writeName(*tcpSnk);

        tcpRtxScanner.registerTcp(*tcpSrc);

        routeout = new route_t(*(net_paths[flow.src][flow.dst]->at(choice)));
        routeout->push_back(tcpSnk);

        total_path_lengths += net_paths[flow.src][flow.dst]->at(choice)->size()/2 - 2;

        assert (net_paths[flow.dst][flow.src]->size() > 0);
        int rchoice = rand()%net_paths[flow.dst][flow.src]->size();
        routein = new route_t(*(net_paths[flow.dst][flow.src]->at(rchoice)));
        routein->push_back(tcpSrc);

        #if LARGE_FLOWSIZE
            int shouldSendFlow = rand()%FLOWSIZE_MULT;
            if (shouldSendFlow == 0) {
                tcpSrc->connect(*routeout, *routein, *tcpSnk, timeFromMs(flow.start_time_ms));
            }
        #else
            tcpSrc->connect(*routeout, *routein, *tcpSnk, timeFromMs(flow.start_time_ms));
        #endif
        //sinkLogger.monitorSink(tcpSnk);
    }

    // Record the setup
    int pktsize = Packet::data_packet_size();
    logfile.write("# pktsize=" + ntoa(pktsize) + " bytes");
    logfile.write("# hostnicrate = " + ntoa(HOST_NIC) + " pkt/sec");
    logfile.write("# corelinkrate = " + ntoa(HOST_NIC*CORE_TO_HOST) + " pkt/sec");
    //logfile.write("# buffer = " + ntoa((double) (queues_na_ni[0][1]->_maxsize) / ((double) pktsize)) + " pkt");
    double rtt = timeAsSec(timeFromUs(RTT));
    logfile.write("# rtt =" + ntoa(rtt));

    // GO!
    cout << "topology  " << total_path_lengths << " " << total_available_paths << " " << total_available_first_hops << endl;
    cout << "starting simulation " << endl;
    while (eventlist.doNextEvent()) {}
    // cout << "end  " << total_packet_bytes << " " << total_path_lengths << " " << total_available_paths << " " << total_available_first_hops << endl;
}

string ntoa(double n) {
    stringstream s;
    s << n;
    return s.str();
}

string itoa(uint64_t n) {
    stringstream s;
    s << n;
    return s.str();
}