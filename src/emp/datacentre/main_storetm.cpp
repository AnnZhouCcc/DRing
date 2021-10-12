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

#if CHOSEN_TOPO == FAT
#include "fat_tree_topology.h"
#elif CHOSEN_TOPO == LEAFSPINE
#include "leaf_spine_topology.h"
#elif CHOSEN_TOPO == RRG
#include "rand_regular_topology.h"
#endif

string tm = "r2r";

uint32_t RTT = 2; // us
int ssthresh = 43; //65 KB
int N=NSW;
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

void store_tm_rrg(ConnectionMatrix *conns, RandRegularTopology* top) {
    string tmfile, rawtmfile;
    if (NHOST == 2988) {
        rawtmfile = tm + "_tm_raw_dring.txt";
        tmfile = tm + "_tm_dring.txt";
    } else {
        rawtmfile = tm + "_tm_raw_rrg.txt";
        tmfile = tm + "_tm_rrg.txt";
    }

    uint64_t** tm = new uint64_t*[NSW];
    for (int i=0;i<NSW;i++){
        tm[i] = new uint64_t[NSW];
        for (int j = 0;j<NSW;j++){
            tm[i][j] = 0;
        }
    }

    ofstream file;
    file.open(rawtmfile);
    int src_sw, dst_sw;
    for (Flow& flow: conns->flows) {
	src_sw = top->ConvertHostToSwitch(flow.src);
	dst_sw = top->ConvertHostToSwitch(flow.dst);
        tm[src_sw][dst_sw] += flow.bytes;

        file << flow.src << " " << flow.dst << " " << flow.bytes << " " << flow.start_time_ms << "\n";
    }
    file.close();

    // ofstream file;
    file.open(tmfile);
    int src_row_id, dst_column_id;
    uint64_t* row;
    for (int count=0; count<NSW; count++) {
        src_row_id = NSW - count - 1;
        row = tm[src_row_id];
        file << src_row_id << "\t";
        for (int dst_column_id=0; dst_column_id<NSW; dst_column_id++) {
            file << row[dst_column_id] << "\t";
        }
        file << "\n";
    }
    file << "\t";
    for (int i=0; i<NSW; i++) {
        file << i << "\t";
    }
    file.close();

    for (int i=0; i<NSW; i++) {
	delete [] tm[i];
    }
    delete [] tm;
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

#ifdef RAND_REGULAR
    store_tm_rrg(conns, top);
#endif
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
