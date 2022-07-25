#ifndef LEAF_SPINE
#define LEAF_SPINE
#include "main.h"
#include "randomqueue.h"
#include "pipe.h"
#include "config.h"
#include "loggers.h"
#include "network.h"
#include "topology.h"
#include "logfile.h"
#include "eventlist.h"
#include <ostream>


#define LSX (3*K/4)
#define LSY (K/4)
//!HACK
//#define LSX 40
//#define LSY 24

#define NL (LSX + LSY)
#define NSP (LSY)
#define NSRV (OVERSUBSCRIPTION*(LSX + LSY)*LSX)

#define NO_OS_SVR(src) (src/OVERSUBSCRIPTION)
#define HOST_TOR_SWITCH(src) (NO_OS_SVR(src)/LSX)

class LeafSpineTopology: public Topology{
 public:
  Pipe * pipes_nup_nlp[NSP][NL];
  Pipe * pipes_nlp_ns[NL][NSRV];
  Queue * queues_nup_nlp[NSP][NL];
  Queue * queues_nlp_ns[NL][NSRV];

  Pipe * pipes_nlp_nup[NL][NSP];
  Pipe * pipes_ns_nlp[NSRV][NL];
  Queue * queues_nlp_nup[NL][NSP];
  Queue * queues_ns_nlp[NSRV][NL];

  Logfile* logfile;

  LeafSpineTopology(Logfile* log,EventList* ev, queue_type qt, string netpathfile, string pathweightfile);

  void init_network();
  virtual pair<vector<double>*, vector<route_t*>*> get_paths(int src, int dest);
  virtual pair<vector<double>*, vector<route_t*>*> get_other_paths(int src, int dest);
  virtual int get_distance(int src, int dest);

  void count_queue(Queue*);
  void print_path(std::ostream& paths,int src,route_t* route);
  vector<int>* get_neighbours(int src) { return NULL;};  
  int ConvertHostToRack(int host) { return HOST_TOR_SWITCH(host);};
  pair<vector<int>, vector<int> > getcsRacks(int clients, int servers);
  void delete_net_paths_rack_based(int numintervals);
  route_t *attach_head_tail(int src, int dst, bool is_same_switch, int rand_choice);
 private:
  map<Queue*,int> _link_usage;
  int find_lp_switch(Queue* queue);
  int find_up_switch(Queue* queue);
  int find_destination(Queue* queue);
};

#endif
