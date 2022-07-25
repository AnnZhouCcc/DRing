#include "../config.h"
#include <sstream>
#include <strstream>
#include <iostream>
#include <string.h>
#include <list>
#include <math.h>
#include <fstream>
#include "../network.h"
#include "../randomqueue.h"
#include "../pipe.h"
#include "../eventlist.h"
#include "../logfile.h"
#include "../loggers.h"
#include "../clock.h"
#include "../tcp.h"
#include "../dctcp.h"
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
#define DEBUG_MODE false
#define PATHWEIGHTS true

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

void exit_error(char* progr) {
    cout << "Usage " << progr << " [UNCOUPLED(DEFAULT)|COUPLED_INC|FULLY_COUPLED|COUPLED_EPSILON] [epsilon][COUPLED_SCALABLE_TCP" << endl;
    exit(1);
}

void print_path(std::ofstream paths,route_t* rt){
  for (unsigned int i=1;i<rt->size()-1;i+=2){
    RandomQueue* q = (RandomQueue*)rt->at(i);
    if (q!=NULL)
      paths << q->str() << " ";
    else 
      paths << "NULL ";
  }
  paths<<endl;
}

void print_path(route_t* rt){
  for (unsigned int i=1;i<rt->size()-1;i+=2){
    RandomQueue* q = (RandomQueue*)rt->at(i);
    if (q!=NULL)
      cout << q->str() << " ";
    else 
      cout << "NULL ";
  }
  cout<<endl;
}

int choose_a_path(vector< pair<int,double> >* path_weights, vector<route_t*>* net_paths, int src_sw, int dst_sw, int dp) {
    // dp means precision
#if PATHWEIGHTS
    int num_paths = path_weights->size();

    if (num_paths == 0) {
        cout << "***Error : main_flowsize.cpp choose_a_path : num_paths=0, src_sw=" << src_sw << ", dst_sw=" << dst_sw << endl;
        exit(1);
    } else {
        double random = rand()/RAND_MAX;

    #if DEBUG_MODE
        cout << "num_paths = " << num_paths << endl;
        cout << "random = " << random << endl;
    #endif

        double sum = 0;
        for (int i=0; i<num_paths; i++) {
            double prev_sum = sum;
            sum += path_weights->at(i).second;

        #if DEBUG_MODE
            cout << path_weights->at(i).first << " " << path_weights->at(i).second << " | " << endl;
        #endif

            if (random<sum && random>=prev_sum) return path_weights->at(i).first;
        }
    }
    exit(1);
#else
    return rand()%net_paths->size();
#endif
}

int main(int argc, char **argv) {
    eventlist.setEndtime(timeFromSec(SIMTIME));
    Clock c(timeFromSec(50 / 100.), eventlist);
    int algo = COUPLED_EPSILON;
    double epsilon, simtime_ms = 1;
    int param, paramo = 0;
    int multiplier, numerator, denominator, solvestart, solveend, korn, dp, mstart, mend, stime, solveinterval, computestart, computeend, computeinterval = 0;
    string paramstring, paramstringo;
    string multiplierstring, numeratorstring, denominatorstring, solvestartstring, solveendstring, kornstring, dpstring, mstartstring, mendstring, stimestring, solveintervalstring, computestartstring, computeendstring, computeintervalstring;
    stringstream filename(ios_base::out);
    string rfile, npfile, pwfile;
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
      cout << "Using subflow count " << subflow_count <<endl;

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

      if (argc>i&&!strcmp(argv[i],"-numerator")){
          numeratorstring = argv[i+1];
          numerator = atoi(argv[i+1]);
          i+=2;
      }
      cout << "Numerator=" << numerator << endl;

      if (argc>i&&!strcmp(argv[i],"-denominator")){
          denominatorstring = argv[i+1];
          denominator = atoi(argv[i+1]);
          i+=2;
      }
      cout << "Denominator=" << denominator << endl;

      if (argc>i&&!strcmp(argv[i],"-solvestart")){
          solvestartstring = argv[i+1];
          solvestart = atoi(argv[i+1]);
          i+=2;
      }
      cout << "SolveStart="<<solvestart<<endl;

      if (argc>i&&!strcmp(argv[i],"-solveend")){
          solveendstring = argv[i+1];
          solveend = atoi(argv[i+1]);
          i+=2;
      }
      cout << "SolveEnd="<<solveend<<endl;

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
      cout << "Using param " << param <<endl;

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

      if (argc>i&&!strcmp(argv[i],"-netpath")){
          npfile = argv[i+1];
          i+=2;
      }
      cout << "Netpath File: " << npfile << endl;

      if (argc>i&&!strcmp(argv[i],"-pathweight")){
          pwfile = argv[i+1];
          i+=2;
      }
      cout << "Pathweight File: " << pwfile << endl;

      if (argc>i&&!strcmp(argv[i],"-dp")){
          dpstring = argv[i+1];
          dp = atoi(argv[i+1]);
          i+=2;
      }
      cout << "Dp = " << dp << endl;

      if (argc>i&&!strcmp(argv[i],"-mstart")){
          mstartstring = argv[i+1];
          mstart = atoi(argv[i+1]);
          i+=2;
      }
      cout << "mstart = " << mstart << endl;
      eventlist.measurement_start_ms = mstart;

      if (argc>i&&!strcmp(argv[i],"-mend")){
          mendstring = argv[i+1];
          mend = atoi(argv[i+1]);
          i+=2;
      }
      cout << "mend = " << mend << endl;
      eventlist.measurement_end_ms = mend;

      if (argc>i&&!strcmp(argv[i],"-stime")){
          stimestring = argv[i+1];
          stime = atoi(argv[i+1]);
          i+=2;
      }
      cout << "stime = " << stime << endl;
      simtime_ms = stime;

      if (argc>i&&!strcmp(argv[i],"-solveinterval")){
          solveintervalstring = argv[i+1];
          solveinterval = atoi(argv[i+1]);
          i+=2;
      }
      cout << "solveinterval = " << solveinterval << endl;

      if (argc>i&&!strcmp(argv[i],"-computestart")){
          computestartstring = argv[i+1];
          computestart = atoi(argv[i+1]);
          i+=2;
      }
      cout << "computestart = " << computestart << endl;

      if (argc>i&&!strcmp(argv[i],"-computeend")){
          computeendstring = argv[i+1];
          computeend = atoi(argv[i+1]);
          i+=2;
      }
      cout << "computeend = " << computeend << endl;

      if (argc>i&&!strcmp(argv[i],"-computeinterval")){
          computeintervalstring = argv[i+1];
          computeinterval = atoi(argv[i+1]);
          i+=2;
      }
      cout << "computeinterval = " << computeinterval << endl;

      eventlist.num_flows_finished = 0;
    
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

#if CHOSEN_TOPO == FAT
    FatTreeTopology* top = new FatTreeTopology(&logfile, &eventlist, RANDOM);
#elif CHOSEN_TOPO == LEAFSPINE
    LeafSpineTopology* top = new LeafSpineTopology(&logfile, &eventlist, RANDOM, npfile, pwfile);
#elif CHOSEN_TOPO == RRG
    RandRegularTopology* top;
    if (conn_matrix == "CLUSTERX") {
        string pwfileprefix = pwfile;
        string pwfilesuffix = "_" + itoa(dp) + "dp.txt";
        top = new RandRegularTopology(&logfile, &eventlist, rfile, RANDOM, conn_matrix, routing, korn, npfile, pwfileprefix, pwfilesuffix, solvestart, solveend, solveinterval, computestart, computeend, computeinterval);
    } else {
        top = new RandRegularTopology(&logfile, &eventlist, rfile, RANDOM, conn_matrix, routing, korn, npfile, pwfile, "", solvestart, solveend, solveinterval, computestart, computeend, computeinterval);
    }
#endif

    ConnectionMatrix* conns = new ConnectionMatrix(NHOST);

    if (conn_matrix == "A2A"){
        conns->setTopoFlowsAllToAll(simtime_ms);
    }
    else if (conn_matrix == "CLUSTERX") {
        conns->setFlowsFromClusterXSmallInterval(top, paramstring, multiplier, numerator, denominator, solvestart, solveend, solveinterval, simtime_ms);
    }
    else if(conn_matrix == "PERM") {
        conns->setRackLevelPermutationFlowsHardCoding(multiplier, simtime_ms);
    }
    else if(conn_matrix == "MIX"){
        conns->setMixFlows(top, param, multiplier, numerator, denominator);
    }
    else {
        cout << "***Error: traffic pattern " << conn_matrix << " no longer supported." << endl;
        exit(1);

        if(conn_matrix == "SAMPLED_PERM"){
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
            conns->setRackLevelRackToRackFlowsHardCoding(multiplier, simtime_ms);
        }
        else if(conn_matrix == "FEW_TO_SOME"){
            if (NHOST == 3072) {
                conns->setRackLevel16To4FlowsHardCoding(multiplier, simtime_ms);
            } else if (NHOST == 2988) {
                conns->setDRingRackLevel16To4FlowsHardCoding(multiplier, simtime_ms);
            } else {
                cout << "Not hard-coded yet." << endl;
            }
        }
        else if(conn_matrix == "FEW_TO_SOME_REPEAT"){
            conns->setFewtoSomeFlowsRepeat(top, param, paramo, multiplier, numerator, denominator);
        }
        else if(conn_matrix == "UNIFORM"){
            conns->setUniform(param);
        }
        else if(conn_matrix == "RANDOM"){
            conns->setRackLevelAllToAllFlowsHardCoding(multiplier, simtime_ms);
        }
        else if(conn_matrix == "FILE"){
            conns->setFlowsFromFile(top, paramstring, multiplier, numerator, denominator);
        }
        else if (conn_matrix == "FILEX") {
            conns->setFlowsFromFileXHardCoding(top, paramstring, multiplier, numerator, denominator);
        }
        else if(conn_matrix == "FLUID_MIX"){ // setFluidMixFlows
        }
        else if (conn_matrix == "TEST") {
            conns->setTestRandomFlows(simtime_ms);
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
    }
    conns->multiplyFlows(multiplier,numerator,denominator);
    conns->printTopoFlows(top, "topoflowsfiles/topoflows_" + conn_matrix + ".txt");
    map<int,vector<int>*>::iterator it;

    // Determine the number of flows we should wait for in measurement
    eventlist.num_flows_threshold = conns->determineNumFlowsThreshold(eventlist.measurement_start_ms, eventlist.measurement_end_ms);
    cout << "num_flows_threshold = " << eventlist.num_flows_threshold << endl;

    cout << "Starting to produce flow paths" << endl;
    typedef pair<int, int> PII;
    int flowID = 0, whichinterval=0, numintervals=1;
    int src_sw, dst_sw, num_paths_srcsw_dstsw, num_paths_dstsw_srcsw;
    vector<route_t*>*** net_paths = top->net_paths_rack_based;
    for (Flow& flow: conns->flows){
        flowID++;
        if(flowID%1000==1)
            cout << "FLOW: " << flow.src << "(" << top->ConvertHostToRack(flow.src)<<") -> "
                 << flow.dst << "("<< top->ConvertHostToRack(flow.dst) << ") bytes: "
                 << flow.bytes << " start_time_ms " << flow.start_time_ms << endl;

	#if CHOSEN_TOPO == LEAFSPINE
		src_sw = top->ConvertHostToRack(flow.src);
		dst_sw = top->ConvertHostToRack(flow.dst);
	#elif CHOSEN_TOPO == RRG
		src_sw = top->ConvertHostToSwitch(flow.src);
		dst_sw = top->ConvertHostToSwitch(flow.dst);
	#endif

    #if PATHWEIGHTS
        num_paths_srcsw_dstsw = net_paths[src_sw][dst_sw]->size();
        num_paths_dstsw_srcsw = net_paths[dst_sw][src_sw]->size();

    #if CHOSEN_TOPO == RRG
        if (conn_matrix == "CLUSTERX") {
            numintervals = (solveend-solvestart) / solveinterval;
            double intervallen = simtime_ms / numintervals;
            whichinterval = int(flow.start_time_ms / intervallen);
        }
    #endif
    #else
        if (!net_paths[src_sw][dst_sw]){

        #if DEBUG_MODE
            cout << "Getting paths from topo src->dst: flowID = " << flowID << endl;	
        #endif

            top->get_paths(src_sw, dst_sw);
	        assert(net_paths[src_sw][dst_sw] != NULL);
        }

        if (!net_paths[dst_sw][src_sw]){

        #if DEBUG_MODE
            cout << "Getting paths from topo dst->src: flowID = " << flowID << endl;	
        #endif

            top->get_paths(dst_sw, src_sw);
	        assert(net_paths[dst_sw][src_sw] != NULL);
        }

        num_paths_srcsw_dstsw = net_paths[src_sw][dst_sw]->size();
        num_paths_dstsw_srcsw = net_paths[dst_sw][src_sw]->size();

    #if DEBUG_MODE
	    cout << "after get_paths: flowID = " << flowID << ", src_sw = " << src_sw << " dst_sw = " << dst_sw << endl;
    #endif

        total_available_paths += num_paths_srcsw_dstsw;
        set<PacketSink *> *first_hops_till_now = new set<PacketSink *>();
        for (unsigned int i=0; i<(unsigned int)num_paths_srcsw_dstsw; i++) {
            route_t *this_route = net_paths[src_sw][dst_sw]->at(i);
            if (this_route->size() > 0) {
                PacketSink *this_first_hop = this_route->at(0); // Queue inherits from PacketSink
                first_hops_till_now->insert(this_first_hop);
            }
        }
        total_available_first_hops += first_hops_till_now->size();

        if (flowID%1000==1){
            cout << "How many paths? = " << num_paths_srcsw_dstsw << endl;
        }

    #if DEBUG_MODE
        cout << "before tcp: flowID = " << flowID << endl;
    #endif

    #endif

        assert (subflow_count == 1);
        tcpSrc = new TcpSrc(NULL, NULL, eventlist);
        tcpSnk = new TcpSink();
        tcpSrc->set_ssthresh(ssthresh*Packet::data_packet_size());
        tcpSrc->set_flowsize(flow.bytes);

    #if DEBUG_MODE
        cout << "before randomly taking paths: flowID = " << flowID << endl;
    #endif

        if (src_sw == dst_sw) {
		    routeout = top->attach_head_tail(flow.src, flow.dst, true, 0);
            routein = top->attach_head_tail(flow.dst, flow.src, true, 0);
	    } else {
            int choice = choose_a_path(top->path_weights_rack_based[whichinterval][src_sw][dst_sw], net_paths[src_sw][dst_sw], src_sw, dst_sw, dp);
            int rchoice = choose_a_path(top->path_weights_rack_based[whichinterval][dst_sw][src_sw], net_paths[dst_sw][src_sw], dst_sw, src_sw, dp);

            if (choice>=num_paths_srcsw_dstsw){
                cout << "***Weird path choice " << choice << " out of " << num_paths_srcsw_dstsw << ", src_sw=" << src_sw << ", dst_sw=" << dst_sw << endl;
                exit(1);
            }
            if (rchoice>=num_paths_dstsw_srcsw){
                cout << "***Weird path rchoice " << rchoice << " out of " << num_paths_dstsw_srcsw << ", src_sw=" << src_sw << ", dst_sw=" << dst_sw << endl;
                exit(1);
            }

            routeout = top->attach_head_tail(flow.src, flow.dst, false, choice);
            routein = top->attach_head_tail(flow.dst, flow.src, false, rchoice);

        #if DEBUG_MODE
            cout << "**debug info** routeout: ";
            for (unsigned int i=0; i<routeout->size(); i++) {
                cout << routeout->at(i)->nodename();
            }
            cout << endl;
            cout << "**debug info** routein: ";
            for (unsigned int i=0; i<routein->size(); i++) {
                cout << routein->at(i)->nodename();
            }
            cout << endl; 
        #endif

	    }

    #if PRINT_PATHS
        paths << "Route from "<< ntoa(src) << " to " << ntoa(dest) << "  (" << choice << ") -> " ;
        print_path(paths,net_paths[src][dest]->at(choice));
    #endif

        total_path_lengths += (routeout->size()-5)/2;

        //last entry is path length
        tcpSrc->setName("tcp_src_" + ntoa(flow.src) + "_" + ntoa(flow.dst) + "_" + ntoa(routeout->size()/2 - 2));
        logfile.writeName(*tcpSrc);

        tcpSnk->setName("tcp_sink_" + ntoa(flow.src) + "_" + ntoa(flow.dst) + "_" + ntoa(routeout->size()/2 - 2));
        logfile.writeName(*tcpSnk);

        tcpRtxScanner.registerTcp(*tcpSrc);

        routeout->push_back(tcpSnk);
        routein->push_back(tcpSrc);

        tcpSrc->connect(*routeout, *routein, *tcpSnk, timeFromMs(flow.start_time_ms));
    }

    cout << "Set up all flows" << endl;
    top->delete_net_paths_rack_based(numintervals);

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
