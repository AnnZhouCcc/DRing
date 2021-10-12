#include "config.h"
#include <sstream>
#include <strstream>
#include <iostream>
#include <string.h>
#include <list>
#include <math.h>
#include <fstream>
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

string rs = "ecmp";

uint32_t RTT = 2; // us
int ssthresh = 43; //65 KB
int N = NSW;
unsigned int subflow_count = 1;
const double SIMTIME = 101;
EventList eventlist;
Logfile* lg;

string ntoa(double n);
string itoa(uint64_t n);

void exit_error(char* progr) {
    cout << "Usage " << progr << " [UNCOUPLED(DEFAULT)|COUPLED_INC|FULLY_COUPLED|COUPLED_EPSILON] [epsilon][COUPLED_SCALABLE_TCP" << endl;
    exit(1);
}

// Copied from compute_store.cpp
// Another copy in rand_regular_topology.cpp; thus add the suffix "..Copy" to differentiate
// AnnC: should have a better way to handle
pair<int, int> extractSwitchIDCopy(string nodename) {
    int src_sw, dst_sw, src_sw_back_start_index;
    int last_index = nodename.length()-1;

    char dst_sw_second_char = nodename[last_index];
    char dst_sw_first_char = nodename[last_index-1];
    if (dst_sw_first_char == '_') {
        string dst_sw_str(1, dst_sw_second_char);
        dst_sw = stoi(dst_sw_str);
        src_sw_back_start_index = last_index-5;
    } else {
        dst_sw = stoi(nodename.substr(last_index-1, 2));
        src_sw_back_start_index = last_index-6;
    }

    char src_sw_second_char = nodename[src_sw_back_start_index];
    char src_sw_first_char = nodename[src_sw_back_start_index-1];
    if (src_sw_first_char == '_') {
        string src_sw_str(1, src_sw_second_char);
        src_sw = stoi(src_sw_str);
    } else {
        src_sw = stoi(nodename.substr(src_sw_back_start_index-1, 2));
    }

    return pair<int, int>(src_sw, dst_sw);
}

void store_netpath(vector<route_t*>*** net_paths) {
    cout << "Writing net_path" << endl;
    string npfile;
    if (NHOST == 2988) {
        npfile = "netpath_" + rs + "_dring.txt";
    } else {
        assert(NHOST == 3072);
        npfile = "netpath_" + rs + "_rrg.txt";
    }

    ofstream file;
    file.open(npfile);
    vector<route_t*>* net_path_a_pair;
    int num_path, src_sw, dst_sw;
    string nodename;
    for (int ssw=0; ssw<NSW; ssw++) {
        for (int dsw=0; dsw<NSW; dsw++) {       
            if (ssw == dsw) {
                file << ssw << " " << dsw << " " << 0 << "\n";
                continue;
            }
            net_path_a_pair = net_paths[ssw][dsw];
            num_path = net_path_a_pair->size();
            file << ssw << " " << dsw << " " << num_path << "\n";

            for (int i=0; i<num_path; i++) {
                for (int j=0; j<net_path_a_pair->at(i)->size(); j=j+2) {
                    nodename = net_path_a_pair->at(i)->at(j)->nodename();
                    src_sw = extractSwitchIDCopy(nodename).first;
                    dst_sw = extractSwitchIDCopy(nodename).second;
                    file << " " << src_sw << "->" << dst_sw;
                }
                file << "\n";
            }
        }
    }

    file.close();
}

int main(int argc, char **argv) {
    eventlist.setEndtime(timeFromSec(SIMTIME));
    Clock c(timeFromSec(50 / 100.), eventlist);
    int algo = COUPLED_EPSILON;
    double epsilon = 1;
    int param, paramo = 0;
    int multiplier, numerator, denominator, korn = 0;
    string paramstring, paramstringo;
    string multiplierstring, numeratorstring, denominatorstring, kornstring;
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

    // Permutation connections
    ConnectionMatrix* conns = new ConnectionMatrix(NHOST);
    //conns->setLocalTraffic(top);
    
    //cout<< "Running sampled A2A with sample rate: "<< (double)param/8000.0 <<endl;
    assert (conn_matrix == "FILE" or conn_matrix == "FEW_TO_SOME" or conn_matrix == "FEW_TO_SOME_REPEAT" or conn_matrix == "RANDOM" or conn_matrix == "RACK_TO_RACK" or conn_matrix == "MIX");
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
        conns->setRacktoRackFlows(top, param, paramo, multiplier, numerator, denominator);
    }
    else if(conn_matrix == "FEW_TO_SOME"){
        conns->setFewtoSomeFlows(top, param, paramo, multiplier, numerator, denominator);
    }
    else if(conn_matrix == "FEW_TO_SOME_REPEAT"){
        conns->setFewtoSomeFlowsRepeat(top, param, paramo, multiplier, numerator, denominator);
    }
    else if(conn_matrix == "UNIFORM"){
        conns->setUniform(param);
    }
    else if(conn_matrix == "RANDOM"){
        int connxs = (NHOST * NHOST / 1000) * param;
        conns->setRandomFlows(connxs);
    }
    else if(conn_matrix == "FILE"){
        conns->setFlowsFromFile(top, paramstring, multiplier, numerator, denominator);
    }
    else if(conn_matrix == "MIX"){
        conns->setMixFlows(top, param, multiplier, numerator, denominator);
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

    cout << "Calculating net_path" << endl;
    int flowID = 0;
    int src_sw, dst_sw;
    vector<route_t*>*** net_paths = top->net_paths_rack_based;
    vector<route_t*>* available_paths_out;
    vector<route_t*>* available_paths_in;
    for (Flow& flow: conns->flows) {
        flowID++;
        if(flowID%1000==0) {
            cout << "FLOW: " << flow.src << "(" << top->ConvertHostToRack(flow.src)<<") -> "
                 << flow.dst << "("<< top->ConvertHostToRack(flow.dst) << ") bytes: "
                 << flow.bytes << " start_time_ms " << flow.start_time_ms << endl;
        }

        #if CHOSEN_TOPO == LEAFSPINE
            src_sw = top->ConvertHostToRack(flow.src);
            dst_sw = top->ConvertHostToRack(flow.dst);
        #elif CHOSEN_TOPO == RRG
            src_sw = top->ConvertHostToSwitch(flow.src);
            dst_sw = top->ConvertHostToSwitch(flow.dst);
        #endif

        if (!net_paths[src_sw][dst_sw]){
            available_paths_out = top->get_paths(src_sw, dst_sw).second;
	        assert(net_paths[src_sw][dst_sw] != NULL);
        } else {
	        available_paths_out = net_paths[src_sw][dst_sw];
	    }

        if (!net_paths[dst_sw][src_sw]){
            available_paths_in = top->get_paths(dst_sw, src_sw).second;
	        assert(net_paths[dst_sw][src_sw]);
        } else {
	        available_paths_in = net_paths[dst_sw][src_sw];
	    }
    }

    store_netpath(net_paths);
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
