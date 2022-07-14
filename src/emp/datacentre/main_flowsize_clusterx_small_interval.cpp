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
#include "rand_regular_topology.h"

// Simulation params
#define PRINT_PATHS 0
#define PERIODIC 0

// Parameters for average flow size experiments
#define LARGE_FLOWSIZE false
#define FLOWSIZE_MULT 0
#define DEBUG_MODE false
#define PW_DETAIL false
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
// extern uint64_t total_packet_bytes;

// vector<route_t*>*** net_paths_rack_based;

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
#if PATHWEIGHTS
    int numpaths = path_weights->size();
    if (numpaths == 0) {
	cout << "Temporary fix for acknowledgement: src_sw = " << src_sw << ",dst_sw = " << dst_sw << endl;
	return rand()%net_paths->size();
    }

    double unit = pow(10,dp);
    double random = (rand()%(int)unit)/unit;

    #if PW_DETAIL
        cout << "unit = " << unit << endl;
        cout << "random = " << random << endl;
        cout << "num_paths = " << numpaths << endl;
    #endif

    double sum = 0, prev_sum = 0;
    for (int i=0; i<numpaths; i++) {
        prev_sum = sum;
        sum += path_weights->at(i).second;

        #if PW_DETAIL
            cout << path_weights->at(i).first << " " << path_weights->at(i).second << " | " << endl;
        #endif

        if (random<sum && random>=prev_sum) return path_weights->at(i).first;
    }
    return -1;
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

    string pwfileprefix = pwfile;
    string pwfilesuffix = "_" + itoa(dp) + "dp.txt";
    RandRegularTopology* top = new RandRegularTopology(&logfile, &eventlist, rfile, RANDOM, routing, korn, npfile, pwfileprefix, pwfilesuffix, solvestart, solveend, solveinterval, computestart, computeend, computeinterval);

    // Permutation connections
    ConnectionMatrix* conns = new ConnectionMatrix(NHOST);
    if (conn_matrix == "CLUSTERX") {
        conns->setFlowsFromClusterXSmallInterval(top, paramstring, multiplier, numerator, denominator, solvestart, solveend, solveinterval, simtime_ms);
    } else{
        cout<<"conn_matrix: "<<conn_matrix<<" not supported. Use CLUSTERX. "<<endl;
        return 0;
    }
    map<int,vector<int>*>::iterator it;

    // Determine the number of flows we should wait for in measurement
    // conns->sortFlowsByStartTime();
    eventlist.num_flows_threshold = conns->determineNumFlowsThreshold(eventlist.measurement_start_ms, eventlist.measurement_end_ms);
    cout << "num_flows_threshold = " << eventlist.num_flows_threshold << endl;

    cout << "Starting to produce flow paths" << endl;
    typedef pair<int, int> PII;
    int flowID = 0;
    for (Flow& flow: conns->flows) {
        flowID++;
        if(flowID%1000==0)
            cout << "FLOW: " << flow.src << "(" << top->ConvertHostToRack(flow.src)<<") -> "
                 << flow.dst << "("<< top->ConvertHostToRack(flow.dst) << ") bytes: "
                 << flow.bytes << " start_time_ms " << flow.start_time_ms << endl;

        int srcsvr = flow.src;
        int dstsvr = flow.dst;
		int srcsw = top->ConvertHostToSwitch(srcsvr);
		int dstsw = top->ConvertHostToSwitch(dstsvr);
        double starttime = flow.start_time_ms;
        int bytes = flow.bytes;

        int numintervals = (solveend-solvestart) / solveinterval;
        double intervallen = simtime_ms / numintervals;
        // int whichinterval = int(starttime / intervallen);
        // int whichinterval = int(int(starttime / intervallen)/2);
        int whichinterval = 0;

        assert (subflow_count == 1);
        tcpSrc = new TcpSrc(NULL, NULL, eventlist);
        tcpSnk = new TcpSink();
        tcpSrc->set_ssthresh(ssthresh*Packet::data_packet_size());

        tcpSrc->set_flowsize(flow.bytes);

        #if DEBUG_MODE
            cout << "before randomly taking paths: flowID = " << flowID << endl;
        #endif

        if (srcsw == dstsw) {
            routeout = top->attach_head_tail(srcsvr, dstsvr, true, 0);
            routein = top->attach_head_tail(dstsvr, srcsvr, true, 0);
        } else {
            int choice = choose_a_path(top->path_weights_rack_based[whichinterval][srcsw][dstsw], top->net_paths_rack_based[srcsw][dstsw], srcsw, dstsw, dp);
            if (choice < 0) {
                cout << "Error with path weights: choice < 0; src_sw = " << srcsw << ", dst_sw = " << dstsw << endl;
                exit(1);
            }
            routeout = top->attach_head_tail(flow.src, flow.dst, false, choice);

            int rchoice = choose_a_path(top->path_weights_rack_based[whichinterval][dstsw][srcsw], top->net_paths_rack_based[dstsw][srcsw], dstsw, srcsw, dp);
            if (rchoice < 0) {
                cout << "Error with path weights: rchoice < 0; src_sw = " << dstsw << ", dst_sw = " << srcsw << endl;
                exit(1);
            }
            routein = top->attach_head_tail(dstsvr, srcsvr, false, rchoice);
        }

        total_path_lengths += (routeout->size()-5)/2;

        #if PRINT_PATHS
                paths << "Route from "<< ntoa(src) << " to " << ntoa(dest) << "  (" << choice << ") -> " ;
                print_path(paths,net_paths[src][dest]->at(choice));
        #endif

        //last entry is path length
        tcpSrc->setName("tcp_src_" + ntoa(srcsvr) + "_" + ntoa(dstsvr) + "_" + ntoa(routeout->size()/2 - 2));
        logfile.writeName(*tcpSrc);

        tcpSnk->setName("tcp_sink_" + ntoa(srcsvr) + "_" + ntoa(dstsvr) + "_" + ntoa(routeout->size()/2 - 2));
        logfile.writeName(*tcpSnk);

        tcpRtxScanner.registerTcp(*tcpSrc);

        routeout->push_back(tcpSnk);
        routein->push_back(tcpSrc);

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

        tcpSrc->connect(*routeout, *routein, *tcpSnk, timeFromMs(starttime));
    }

    cout << "Set up all flows" << endl;
    int numintervals = (solveend-solvestart) / solveinterval;
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
