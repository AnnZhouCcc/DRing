#include "leaf_spine_topology.h"
#include <vector>
#include <stdlib.h>
#include <algorithm>
#include "string.h"
#include <sstream>
#include <strstream>
#include <iostream>
#include "main.h"


const bool USE_DISJOINT = false;

extern uint32_t RTT;

string ntoa(double n);
string itoa(uint64_t n);

extern int N;

LeafSpineTopology::LeafSpineTopology(Logfile* lg, EventList* ev, queue_type qt){
  logfile = lg;
  eventlist = ev;
  qtype = qt;
  
  N = NSRV;

  int num_links = (N/OVERSUBSCRIPTION) * 2;
  
  srand ( time(NULL));

  init_network();

  net_paths_rack_based = new vector<route_t*>**[NSW];
  for (int i=0;i<NSW;i++){
  	net_paths_rack_based[i] = new vector<route_t*>*[NSW];
  	for (int j = 0;j<NSW;j++){
  		net_paths_rack_based[i][j] = NULL;
  	}
  }
}

void LeafSpineTopology::init_network(){
  QueueLoggerSampling* queueLogger;

  for (int j=0;j<NSP;j++){
    for (int k=0;k<NL;k++){
      queues_nup_nlp[j][k] = NULL;
      pipes_nup_nlp[j][k] = NULL;
      queues_nlp_nup[k][j] = NULL;
      pipes_nlp_nup[k][j] = NULL;
    }
  }
  
  for (int j=0;j<NL;j++)
    for (int k=0;k<NSRV;k++){
      queues_nlp_ns[j][k] = NULL;
      pipes_nlp_ns[j][k] = NULL;
      queues_ns_nlp[k][j] = NULL;
      pipes_ns_nlp[k][j] = NULL;
    }

    cout<<"Link Speed: "<<speedFromPktps(HOST_NIC)<<endl;
    mem_b queue_size = SWITCH_BUFFER * Packet::data_packet_size();

    // lower layer switch to server
    for (int j = 0; j < NL; j++) {
        for (int l = 0; l < LSX * OVERSUBSCRIPTION; l++) {
           int k = j * LSX * OVERSUBSCRIPTION + l;
           int delay = 1000000;
           // Downlink
           queueLogger = new QueueLoggerSampling(timeFromMs(delay), *eventlist);
           //queueLogger = NULL;
           logfile->addLogger(*queueLogger);

           queues_nlp_ns[j][k] = alloc_queue(queueLogger, HOST_NIC, queue_size); //new RandomQueue(speedFromPktps(HOST_NIC), memFromPkt(SWITCH_BUFFER + RANDOM_BUFFER), *eventlist, queueLogger, memFromPkt(RANDOM_BUFFER));
           queues_nlp_ns[j][k]->setName("LS_" + ntoa(j) + "-" + "DST_" +ntoa(k));
           logfile->writeName(*(queues_nlp_ns[j][k]));

           pipes_nlp_ns[j][k] = new Pipe(timeFromUs(RTT), *eventlist);
           pipes_nlp_ns[j][k]->setName("Pipe-nt-ns-" + ntoa(j) + "-" + ntoa(k));
           logfile->writeName(*(pipes_nlp_ns[j][k]));
           
           // Uplink
           queueLogger = new QueueLoggerSampling(timeFromMs(delay), *eventlist);
           logfile->addLogger(*queueLogger);
           queues_ns_nlp[k][j] = alloc_queue(queueLogger, HOST_NIC, queue_size); //new RandomQueue(speedFromPktps(HOST_NIC), memFromPkt(SWITCH_BUFFER + RANDOM_BUFFER), *eventlist, queueLogger, memFromPkt(RANDOM_BUFFER));
           queues_ns_nlp[k][j]->setName("SRC_" + ntoa(k) + "-" + "LS_"+ntoa(j));
           logfile->writeName(*(queues_ns_nlp[k][j]));
           
           pipes_ns_nlp[k][j] = new Pipe(timeFromUs(RTT), *eventlist);
           pipes_ns_nlp[k][j]->setName("Pipe-ns-nt-" + ntoa(k) + "-" + ntoa(j));
           logfile->writeName(*(pipes_ns_nlp[k][j]));
        }
    }

    /*    for (int i = 0;i<NSRV;i++){
      for (int j = 0;j<NK;j++){
	printf("%p/%p ",queues_ns_nlp[i][j], queues_nlp_ns[j][i]);
      }
      printf("\n");
      }*/
    
    //Lower layer to upper layer 
    for (int j = 0; j < NL; j++) {
      //Connect the lower layer switch to the upper layer switches 
      for (int k=0; k<NSP;k++){
         // Downlink
         queueLogger = new QueueLoggerSampling(timeFromMs(1000), *eventlist);
         logfile->addLogger(*queueLogger);
         queues_nup_nlp[k][j] = alloc_queue(queueLogger, HOST_NIC, queue_size); //new RandomQueue(speedFromPktps(HOST_NIC), memFromPkt(SWITCH_BUFFER + RANDOM_BUFFER), *eventlist, queueLogger, memFromPkt(RANDOM_BUFFER));
         queues_nup_nlp[k][j]->setName("US_" + ntoa(k) + "-" + "LS_"+ntoa(j));
         logfile->writeName(*(queues_nup_nlp[k][j]));
         
         pipes_nup_nlp[k][j] = new Pipe(timeFromUs(RTT), *eventlist);
         pipes_nup_nlp[k][j]->setName("Pipe-na-nt-" + ntoa(k) + "-" + ntoa(j));
         logfile->writeName(*(pipes_nup_nlp[k][j]));
         
         // Uplink
         queueLogger = new QueueLoggerSampling(timeFromMs(1000), *eventlist);
         logfile->addLogger(*queueLogger);
         queues_nlp_nup[j][k] = alloc_queue(queueLogger, HOST_NIC, queue_size); //new RandomQueue(speedFromPktps(HOST_NIC), memFromPkt(SWITCH_BUFFER + RANDOM_BUFFER), *eventlist, queueLogger, memFromPkt(RANDOM_BUFFER));
         queues_nlp_nup[j][k]->setName("LS_" + ntoa(j) + "-" + "US_"+ntoa(k));
         logfile->writeName(*(queues_nlp_nup[j][k]));
         
         pipes_nlp_nup[j][k] = new Pipe(timeFromUs(RTT), *eventlist);
         pipes_nlp_nup[j][k]->setName("Pipe-nt-na-" + ntoa(j) + "-" + ntoa(k));
         logfile->writeName(*(pipes_nlp_nup[j][k]));
      }
    }

    /*for (int i = 0;i<NK;i++){
      for (int j = 0;j<NK;j++){
	printf("%p/%p ",queues_nlp_nup[i][j], queues_nup_nlp[j][i]);
      }
      printf("\n");
      }*/
}

void check_non_null(route_t* rt){
  int fail = 0;
  for (unsigned int i=1;i<rt->size()-1;i+=2)
    if (rt->at(i)==NULL){
      fail = 1;
      break;
    }
  
  if (fail){
    //    cout <<"Null queue in route"<<endl;
    for (unsigned int i=1;i<rt->size()-1;i+=2)
      printf("%p ",rt->at(i));

    cout<<endl;
    assert(0);
  }
}



int LeafSpineTopology::get_distance(int src, int dest){
  if (HOST_TOR_SWITCH(src)==HOST_TOR_SWITCH(dest)) return 0;
  else return 2;
}



pair<vector<double>*, vector<route_t*>*> LeafSpineTopology::get_other_paths(int src, int dest){
	return get_paths(src, dest);
}

pair<vector<double>*, vector<route_t*>*> LeafSpineTopology::get_paths(int src, int dest){
  vector<route_t*>* paths = new vector<route_t*>();
  vector<double>* weights = NULL;

  route_t* routeout;

  if (HOST_TOR_SWITCH(src)==HOST_TOR_SWITCH(dest)){
    // Queue* pqueue = new Queue(speedFromPktps(HOST_NIC), memFromPkt(FEEDER_BUFFER), *eventlist, NULL);
    // pqueue->setName("PQueue_" + ntoa(src) + "_" + ntoa(dest));
    // logfile->writeName(*pqueue);
  
    routeout = new route_t();
    // routeout->push_back(pqueue);

    // routeout->push_back(queues_ns_nlp[src][HOST_TOR_SWITCH(src)]);
    // routeout->push_back(pipes_ns_nlp[src][HOST_TOR_SWITCH(src)]);

    // routeout->push_back(queues_nlp_ns[HOST_TOR_SWITCH(dest)][dest]);
    // routeout->push_back(pipes_nlp_ns[HOST_TOR_SWITCH(dest)][dest]);

    paths->push_back(routeout);
    net_paths_rack_based[HOST_TOR_SWITCH(src)][HOST_TOR_SWITCH(dest)] = paths;

    // check_non_null(routeout);
    // return pair<vector<double>*, vector<route_t*>*>(weights, paths);
  }
  else{

    //there are NSP paths between the source and the destination
    for (int upper = 0;upper < NSP; upper++){
      //upper is nup
      // Queue* pqueue = new Queue(speedFromPktps(HOST_NIC), memFromPkt(FEEDER_BUFFER), *eventlist, NULL);
      // pqueue->setName("PQueue_" + ntoa(src) + "_" + ntoa(dest));
      // logfile->writeName(*pqueue);
      
      routeout = new route_t();
      // routeout->push_back(pqueue);
      
      // routeout->push_back(queues_ns_nlp[src][HOST_TOR_SWITCH(src)]);
      // routeout->push_back(pipes_ns_nlp[src][HOST_TOR_SWITCH(src)]);

      routeout->push_back(queues_nlp_nup[HOST_TOR_SWITCH(src)][upper]);
      routeout->push_back(pipes_nlp_nup[HOST_TOR_SWITCH(src)][upper]);

      routeout->push_back(queues_nup_nlp[upper][HOST_TOR_SWITCH(dest)]);
      routeout->push_back(pipes_nup_nlp[upper][HOST_TOR_SWITCH(dest)]);
      
      // routeout->push_back(queues_nlp_ns[HOST_TOR_SWITCH(dest)][dest]);
      // routeout->push_back(pipes_nlp_ns[HOST_TOR_SWITCH(dest)][dest]);
      
      paths->push_back(routeout);
      check_non_null(routeout);
      net_paths_rack_based[HOST_TOR_SWITCH(src)][HOST_TOR_SWITCH(dest)] = paths;
    }
    //return paths;
  }
  return pair<vector<double>*, vector<route_t*>*>(weights, paths);
}

route_t *LeafSpineTopology::attach_head_tail(int src, int dst, bool is_same_switch, int rand_choice) {
        int src_sw = ConvertHostToRack(src);
        int dst_sw = ConvertHostToRack(dst);
	route_t *this_route = new route_t(*(net_paths_rack_based[src_sw][dst_sw]->at(rand_choice)));

        if (is_same_switch) {
                assert(rand_choice == 0);
                assert(this_route->size() == 0);

		Queue* pqueue = new Queue(speedFromPktps(HOST_NIC), memFromPkt(FEEDER_BUFFER), *eventlist, NULL);
		pqueue->setName("PQueue_" + ntoa(src) + "_" + ntoa(dst));
		logfile->writeName(*pqueue);

		this_route->push_back(pqueue);
		this_route->push_back(queues_ns_nlp[src][HOST_TOR_SWITCH(src)]);
		this_route->push_back(pipes_ns_nlp[src][HOST_TOR_SWITCH(src)]);

		this_route->push_back(queues_nlp_ns[HOST_TOR_SWITCH(dst)][dst]);
		this_route->push_back(pipes_nlp_ns[HOST_TOR_SWITCH(dst)][dst]);
	} else {
		assert(this_route->size() > 0);

		Queue* pqueue = new Queue(speedFromPktps(HOST_NIC), memFromPkt(FEEDER_BUFFER), *eventlist, NULL);
		pqueue->setName("PQueue_" + ntoa(src) + "_" + ntoa(dst));
		logfile->writeName(*pqueue);
		this_route->push_front(pipes_ns_nlp[src][HOST_TOR_SWITCH(src)]);
		this_route->push_front(queues_ns_nlp[src][HOST_TOR_SWITCH(src)]);
		this_route->push_front(pqueue);

		this_route->push_back(queues_nlp_ns[HOST_TOR_SWITCH(dst)][dst]);
		this_route->push_back(pipes_nlp_ns[HOST_TOR_SWITCH(dst)][dst]);
	}
	return this_route;
}

void LeafSpineTopology::delete_net_paths_rack_based() {
        for (int i=0; i<NSW; i++) {
                for (int j=0; j<NSW; j++) {
                        if (net_paths_rack_based[i][j]) {
                        for (auto p : (*net_paths_rack_based[     i][j])) {
                                delete p;
                        }
                        net_paths_rack_based[i][j]->clear();
                        delete net_paths_rack_based[i][j];
                        }
                }
                delete [] net_paths_rack_based[i];
        }
	delete [] net_paths_rack_based;
}

void LeafSpineTopology::count_queue(Queue* queue){
  if (_link_usage.find(queue)==_link_usage.end()){
    _link_usage[queue] = 0;
  }
  _link_usage[queue] = _link_usage[queue] + 1;
}

int LeafSpineTopology::find_lp_switch(Queue* queue){
  //first check ns_nlp
  for (int i=0;i<NSRV;i++)
    for (int j = 0;j<NL;j++)
      if (queues_ns_nlp[i][j]==queue)
	      return j;

  //only count nup to nlp
  count_queue(queue);

  for (int i=0;i<NSP;i++)
    for (int j = 0;j<NL;j++)
      if (queues_nup_nlp[i][j]==queue)
	      return j;

  return -1;
}

int LeafSpineTopology::find_up_switch(Queue* queue){
  count_queue(queue);
  //check nlp_nup
  for (int i=0;i<NL;i++)
    for (int j = 0;j<NSP;j++)
      if (queues_nlp_nup[i][j]==queue)
	      return j;
  return -1;
}


int LeafSpineTopology::find_destination(Queue* queue){
  //first check nlp_ns
  for (int i=0;i<NL;i++)
    for (int j = 0;j<NSRV;j++)
      if (queues_nlp_ns[i][j]==queue)
	return j;

  return -1;
}

void LeafSpineTopology::print_path(std::ostream &paths,int src,route_t* route){
  paths << "SRC_" << src << " ";
  
  if (route->size()/2==2){
    paths << "LS_" << find_lp_switch((RandomQueue*)route->at(1)) << " ";
    paths << "DST_" << find_destination((RandomQueue*)route->at(3)) << " ";
  } else if (route->size()/2==4){
    paths << "LS_" << find_lp_switch((RandomQueue*)route->at(1)) << " ";
    paths << "US_" << find_up_switch((RandomQueue*)route->at(3)) << " ";
    paths << "LS_" << find_lp_switch((RandomQueue*)route->at(5)) << " ";
    paths << "DST_" << find_destination((RandomQueue*)route->at(7)) << " ";
  } else {
    paths << "Wrong hop count " << ntoa(route->size()/2);
  }
  
  paths << endl;
}

pair<vector<int>, vector<int> > LeafSpineTopology::getcsRacks(int clients, int servers){
   vector<int> clientracks, serverracks;
   vector<int> racks;
   for(int i=0; i<NL; i++){
    racks.push_back(i);
   }
   std::random_shuffle(racks.begin(), racks.end());
   int cCovered=0, sCovered=0;
   int curr_rack_id=0;
   while(curr_rack_id < NL and cCovered < clients){
    int rack = racks[curr_rack_id];
    cout<<"Client rack: "<<rack<<endl;
    clientracks.push_back(rack);
    cCovered += LSX;
    curr_rack_id++;
   }
   while(curr_rack_id < NL and sCovered < servers){
    int rack = racks[curr_rack_id];
    cout<<"Server rack: "<<rack<<endl;
    serverracks.push_back(rack);
    sCovered += LSX;
    curr_rack_id++;
   }

   if (cCovered < clients or sCovered < servers){
    cout << "Not enough racks for C-S model traffic with C=" << clients << " S=" << servers << endl;
    exit(0);
   }

   return pair<vector<int>, vector<int> > (clientracks, serverracks);
}

