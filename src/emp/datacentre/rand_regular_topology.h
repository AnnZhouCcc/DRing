#ifndef RAND_REGULAR
#define RAND_REGULAR
#include "main.h"
#include "../randomqueue.h"
#include "../pipe.h"
#include "../config.h"
#include "../loggers.h"
#include "../network.h"
#include "topology.h"
#include "../logfile.h"
#include "../eventlist.h"
#include "GraphElements.h"
#include "Graph.h"
#include <ostream>

enum FIND_PATH_ALGORITHM
{
    KSHORT,
    KDISJOINT,
    ECMP,
    ECMP_DAG,
    FIRST_HOP_INDIRECTION,
    SHORTESTN,
    SHORTEST2,
};

// Hardcoding number of switches, ports for now

#define REDUCED_NHOST (NHOST/OVERSUBSCRIPTION)

#define SVRPORTS (OVERSUBSCRIPTION * (REDUCED_NHOST%NSW==0?REDUCED_NHOST/NSW:REDUCED_NHOST/NSW+2)) // AnnC: change from +1 to +2 for the scalability test
#define HETERO (REDUCED_NHOST%NSW==0?0:1)

class RandRegularTopology: public Topology{
 public:
  // sw_sw: lower index to higher index = up link etc.
  Pipe * pipes_sw_sw[NSW][NSW];
  Queue * queues_sw_sw[NSW][NSW];
  
  // These are for switch to server "down" links
  Pipe * pipes_sw_svr[NSW][SVRPORTS];
  Queue * queues_sw_svr[NSW][SVRPORTS];

  // These are for svr to switch "up" links
  Pipe * pipes_svr_sw[NSW][SVRPORTS];
  Queue * queues_svr_sw[NSW][SVRPORTS];

  Logfile* logfile;

  FIND_PATH_ALGORITHM find_path_alg;
  int korn;
  void delete_net_paths_rack_based(int numintervals);
  route_t *attach_head_tail(int src, int dst, bool is_same_switch, int rand_choice);

  RandRegularTopology(Logfile* log,EventList* ev, string graphFile, queue_type qt=RANDOM, string conn_matrix="CLUSTERX", string alg="ecmp", int k=0, string netpathFile="none", string pathweightfileprefix="none", string pathweightfilesuffix="none", int solvestart=0, int solveend=0, int solveinterval=0, int computestart=0, int computeend=0, int computeinterval=0);
  RandRegularTopology(Logfile* log,EventList* ev, string graphFile, queue_type qt=RANDOM, string conn_matrix="CLUSTERX", string alg="ecmp", int k=0, int numfaillinks=0, int failseed=0, string netpathFile="none", string pathweightfileprefix="none", string pathweightfilesuffix="none", int solvestart=0, int solveend=0, int solveinterval=0, int computestart=0, int computeend=0, int computeinterval=0, string trafficname="none", string serverfile="none");

  void read_netpathfile(string netpathfile, vector<route_t *>***net_paths);

  void init_network();
  void init_network_withfaillinks();
  virtual pair<vector<double>*, vector<route_t*>*> get_paths(int src, int dest);
  virtual pair<vector<double>*, vector<route_t*>*> get_other_paths(int src, int dest);
  virtual pair<vector<double>*, vector<route_t*>*> get_paths_helper(int src, int dest, FIND_PATH_ALGORITHM find_path_alg);
  pair<vector<double>*, vector<route_t*>*> get_paths_helper_test_transit(int src, int dest, FIND_PATH_ALGORITHM find_path_alg);

  virtual int get_distance(int src, int dest);

//  void print_path(std::ofstream& paths,int src,route_t* route);
  vector<int>* get_neighbours(int src) { return NULL;};

 private:

  Graph* myGraph;
  map<int, map<int, map<BaseVertex*, double> > > nextHops;
  vector<int>* adjMatrix[NSW];
  int linkFailure[NSW][NSW];
  int partitions[NSW];

  int shortestPathLen[NSW][NSW];

  void populateNextHops(int dest_sw);
  int find_switch(Queue* queue);
  int find_destination(Queue* queue);
  unsigned int ConvertHostToSwitchPort(int host);
  int get_number_of_hosts(int torSwitch);

 public:
  vector<int> hostToSwitchArr;
  int ConvertHostToSwitch(int host);
  int get_part(int sw) {return partitions[sw];}
  map<pair<int, int>, pair<vector<double>*, vector<route_t*>* > > pathcache;
  //all pairs shortest paths
  void floydWarshall();
  int ConvertHostToRack(int host) { return ConvertHostToSwitch(host); }
  pair<vector<int>, vector<int> > getcsRacks(int clients, int servers);
  int getHostsInRack(int rack);
};

int rrg_randpath_weighted(vector<route_t*>* paths);

#endif

