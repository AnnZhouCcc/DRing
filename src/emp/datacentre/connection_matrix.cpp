#include "connection_matrix.h"
#include "leaf_spine_topology.h"
#include <string.h>
#include <iostream>
#include <algorithm>
#include <sys/types.h>
#include <unistd.h>
#include <limits.h>
#include <fstream>
#include "../tcppacket.h"
#include <bits/stdc++.h>
// #include <stdc++.h>
#include <math.h>
#include <random>
#include <iostream>
#include <set>
#include <queue>

int large_flow_threshold = 10 * 1024 * 1024;

ConnectionMatrix::ConnectionMatrix(int n)
{
  N = n;
  scale = mean_bytes * (shape - 1)/shape;
  cout << "scale = " << scale << endl;
  exp_distribution = std::exponential_distribution<double>(shape);
}


//sampled random permutation
void ConnectionMatrix::setPermutation(int conn){
  int is_dest[N],dest,pos;
  int to[N];
  vector<int> perm_tmp;
  
  for (int i=0;i<N;i++){
    is_dest[i] = 0;
    to[N] = -1;
    perm_tmp.push_back(i);
  }

  for (int src = 0; src < N; src++) {
    do {
      pos = rand()%perm_tmp.size();
    } while(src==perm_tmp[pos]&&perm_tmp.size()>1);

    dest = perm_tmp[pos];
    assert(src!=dest);

    perm_tmp.erase(perm_tmp.begin()+pos);
    to[src] = dest;
  }

  for (int i = 0;i<conn;i++){
    if (!perm_tmp.size())
      for (int i=0;i<N;i++){
	perm_tmp.push_back(i);
      }

    pos = rand()%perm_tmp.size();
    int src = perm_tmp[pos];
    perm_tmp.erase(perm_tmp.begin()+pos);

    if (connections.find(src)==connections.end()){
      connections[src] = new vector<int>();
    }
    
    connections[src]->push_back(to[src]);
  }
}

void ConnectionMatrix::setPermutation(){
  int is_dest[N],dest;
  
  for (int i=0;i<N;i++)
    is_dest[i] = 0;

  for (int src = 0; src < N; src++) {
    vector<int>* destinations = new vector<int>();
      
    int r = rand()%(N-src);
    for (dest = 0;dest<N;dest++){
      if (r==0&&!is_dest[dest])
       break;
      if (!is_dest[dest])
       r--;
    }

    if (r!=0||is_dest[dest]){
      cout << "Wrong connections r " <<  r << "is_dest "<<is_dest[dest]<<endl;
      exit(1);
    }
      
    if (src==dest){
      //find first other destination that is different!
      do {
	dest = (dest+1)%N;
      }
      while (is_dest[dest]);
	
      if (src==dest){
	printf("Wrong connections 2!\n");
	exit(1);
      }
    }
    is_dest[dest] = 1;
    destinations->push_back(dest);

    connections[src] = destinations;    
  }
}

void ConnectionMatrix::setStride(int S){
  for (int src = 0;src<N; src++) {
    int dest = (src+S)%N;

    connections[src] = new vector<int>();
    connections[src]->push_back(dest);
  }
}

void ConnectionMatrix::setLocalTraffic(Topology* top){
  for (int src = 0;src<N;src++){
    connections[src] = new vector<int>();
    vector<int>* neighbours = top->get_neighbours(src);
    for (unsigned int n=0;n<neighbours->size();n++)
      connections[src]->push_back(neighbours->at(n));
  }
}

void ConnectionMatrix::setRandomFlows(int cnx, double simtime_ms){
  // cnx = cnx/3;
  // cnx = cnx*3;
  cout<<"Num flows: "<<cnx << endl;
  for (int conn = 0;conn<cnx; conn++) {
    int src = rand()%N;
    int dest = rand()%N;
    int bytes = genFlowBytes();
    int mss = 1500;
    // ignore flows > 100 MB
    while (bytes > 10 * 1024 * 1024){
        bytes = genFlowBytes();
    }
    //bytes = 2 * 1024 * 1024;
    bytes = mss * ((bytes+mss-1)/mss);
    // bytes = bytes*3;
    // bytes = bytes/3;
    // double simtime_ms = 50.0;
    double start_time_ms = drand() * simtime_ms;
    flows.push_back(Flow(src, dest, bytes, start_time_ms));
  }
}

void ConnectionMatrix::setRandom(int cnx){
  cout<<"Num connections: "<<endl;
  for (int conn = 0;conn<cnx; conn++) {
    int src = rand()%N;
    int dest = rand()%N;

    if (connections.find(src)==connections.end()){
      connections[src] = new vector<int>();
    }

    connections[src]->push_back(dest);
  }
}

void ConnectionMatrix::setVL2(){
  for (int src = 0;src<N; src++) {
    connections[src] = new vector<int>();

    //need to draw a number from VL2 distribution
    int crt = -1;
    double coin = drand();
    if (coin<0.3)
      crt = 1;
    else if (coin<0.35)
      crt = 1+rand()%10;
    else if (coin<0.85)
      crt = 10;
    else if (coin<0.95)
      crt = 10+rand()%70;
    else 
      crt = 80;

    for (int i = 0;i<crt;i++){
      int dest = rand()%N;
      if (src==dest){
	i--;
	continue;
      }
      connections[src]->push_back(dest);
    }
  }
}

vector<connection*>* ConnectionMatrix::getAllConnections(){
  vector<connection*>* ret = new vector<connection*>();
  vector<int>* destinations;
  map<int,vector<int>*>::iterator it;

  for (it = connections.begin(); it!=connections.end();it++){
    int src = (*it).first;
    destinations = (vector<int>*)(*it).second;
    
    vector<int> subflows_chosen;
    
    for (unsigned int dst_id = 0;dst_id<destinations->size();dst_id++){
      connection* tmp = new connection();
      tmp->src = src;
      tmp->dst = destinations->at(dst_id);
      ret->push_back(tmp);
    }
  }
  return ret;
}

void ConnectionMatrix::setStaggeredRandom(Topology* top,int conns,double local){
  for (int conn = 0;conn<conns; conn++) {
    int src = rand()%N;

    if (connections.find(src)==connections.end()){
      connections[src] = new vector<int>();
    }

    vector<int>* neighbours = top->get_neighbours(src);

    int dest;
    if (drand()<local){
      dest = neighbours->at(rand()%neighbours->size());
    }
    else {
      dest = rand()%N;
    }
    connections[src]->push_back(dest);
  }
}

void ConnectionMatrix::setStaggeredPermutation(Topology* top,double local){
  int is_dest[N];
  int dest = -1,i,found = 0;

  memset(is_dest,0,N*sizeof(int));

  for (int src = 0;src<N; src++) {
    connections[src] = new vector<int>();
    vector<int>* neighbours = top->get_neighbours(src);

    double v = drand();
    //cout<<src<<" : "<<v<<" : "<<local<<" : "<<neighbours<<endl;
    if (v<local){
      i = 0;
      do {
        found = 0;
        int nbr = rand()%neighbours->size();
        cout<<nbr<<endl;
        dest = neighbours->at(nbr);
        if (is_dest[dest])
          found = 1;
      }
      while (found && i++<15);
   }

        //cout<<"found: "<<found<<" , i: " << i<< " , dest: "<<dest<<endl;

    if (v>=local || (v<local&&found)){
      dest = rand()%N;
      while (is_dest[dest])
	dest = (dest+1)%N;
    }

    assert(dest>=0&&dest<N);
    assert(is_dest[dest]==0);
     
    connections[src]->push_back(dest);
    is_dest[dest] = 1;
  }
}

void ConnectionMatrix::setManytoMany(int c){
  vector<int> hosts;
  int t,f;
  unsigned int i,j;

  for (i=0;i<(unsigned int)c;i++){
    do {
      t = rand()%N;
      f = 0;
      for (j=0;j<hosts.size();j++){
        if (hosts[j]==t){
          f = 1;
          break;
        }
      }
    }while(f);

    hosts.push_back(t);
  }

  for (i=0;i<hosts.size();i++){
    connections[hosts[i]] = new vector<int>();
    for (j=0;j<hosts.size();j++){
      if (i==j)
        continue;
      connections[hosts[i]]->push_back(hosts[j]);
    }
  }
}

void ConnectionMatrix::setFewtoSome(Topology *top, int nmasters, int nclients){
  cout<<"Few to some: "<<nmasters<<" , "<<nclients<<endl;
  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
	  }
      maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  cout<<"Maxrackid: "<<maxrackid<<endl;
  bool* switch_covered = new bool[maxrackid];
  std::fill(switch_covered, switch_covered + maxrackid, false);

  vector<int> mastersvrs, clientsvrs;


  pair<vector<int>, vector<int> > chosenracks = top->getcsRacks(nmasters, nclients);

  int curr=0;
  cout<<"clientracks: ";
  while(nmasters>0){
	//int rack = rand()%maxrackid;
	//while(switch_covered[rack]) rack = rand()%maxrackid;
	int rack = chosenracks.first[curr++]; 
   cout<<rack<<",";
	switch_covered[rack] = true;
  	for (int i=0;i<N && nmasters>0;i++){
    	int tor = top->ConvertHostToRack(i);
		if(tor == rack){
			mastersvrs.push_back(i);
			nmasters--;
		}
	}
  }
  cout<<endl;

  curr=0;
  cout<<"serverracks: ";
  while(nclients>0){
	//int clientrack = rand()%maxrackid;
	//while(switch_covered[clientrack]) clientrack = rand()%maxrackid;
	int clientrack = chosenracks.second[curr++]; 
   cout<<clientrack<<",";
	switch_covered[clientrack] = true;
	for (int i=0;i<N && nclients>0;i++){
		int tor = top->ConvertHostToRack(i);
		if(tor == clientrack){
			clientsvrs.push_back(i);
			nclients--;
		}
	}
  }
  cout<<endl;

  for(int master: mastersvrs){
	connections[master] = new vector<int>();
	for(int client: clientsvrs) connections[master]->push_back(client);
  }
  /*
  for(int client: clientsvrs){
	connections[client] = new vector<int>();
	for(int master: mastersvrs) connections[client]->push_back(master);
  }
  */
}



void ConnectionMatrix::setRacktoRackFlows(Topology *top, int nmasters, int nclients, int multiplier, int numerator, int denominator){
  cout<<"Rack to rack: "<<nmasters<<" , "<<nclients<<endl;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
	  }
      maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  cout<<"Maxrackid: "<<maxrackid<<endl;
  bool* switch_covered = new bool[maxrackid];

  int _nmasters = nmasters, _nclients = nclients;
  for (int inst=0; inst<1; inst++){
      // Have a gap of 10 sec between every instance
      double base_start_ms = 1 * 1000.0 * inst;
      std::fill(switch_covered, switch_covered + maxrackid, false);
      nmasters = _nmasters;
      nclients = _nclients;

      vector<int> mastersvrs, clientsvrs;
      pair<vector<int>, vector<int> > chosenracks = top->getcsRacks(nmasters, nclients);

      int curr=0;
      cout<<"clientracks: ";
      while(nmasters>0){
        //int rack = rand()%maxrackid;
        //while(switch_covered[rack]) rack = rand()%maxrackid;
        int rack = chosenracks.first[curr++]; 
        cout<<rack<<",";
        switch_covered[rack] = true;
        for (int i=0;i<N && nmasters>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == rack){
                mastersvrs.push_back(i);
                nmasters--;
            }
        }
      }
      cout<<endl;
      curr=0;
      cout<<"serverracks: ";
      while(nclients>0){
        //int clientrack = rand()%maxrackid;
        //while(switch_covered[clientrack]) clientrack = rand()%maxrackid;
        int clientrack = chosenracks.second[curr++]; 
       cout<<clientrack<<",";
        switch_covered[clientrack] = true;
        for (int i=0;i<N && nclients>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == clientrack){
                clientsvrs.push_back(i);
                nclients--;
            }
        }
      }
      cout<<endl;

      for (int ii=0; ii<multiplier; ii++){
      // for (int ii=0; ii<4; ii++){
          for(int master: mastersvrs){
            for(int client: clientsvrs){
                int bytes = genFlowBytes();
                // ignore flows > 100 MB
                while (bytes > 10 * 1024 * 1024){
                    bytes = genFlowBytes();
                }
                //bytes = 2 * 1024 * 1024;
                bytes = mss * ((bytes+mss-1)/mss);
                double simtime_ms = 49.0;
                double start_time_ms = base_start_ms + drand() * simtime_ms;
                flows.push_back(Flow(master, client, bytes, start_time_ms));
            }
          }
      }

      if (denominator > 0) {
          for(int master: mastersvrs){
            for(int client: clientsvrs){
	        int should_add = rand()%denominator;
		if (should_add < numerator) {
                    int bytes = genFlowBytes();
                    // ignore flows > 100 MB
                    while (bytes > 10 * 1024 * 1024){
                        bytes = genFlowBytes();
                    }
                    //bytes = 2 * 1024 * 1024;
                    bytes = mss * ((bytes+mss-1)/mss);
                    double simtime_ms = 49.0;
                    double start_time_ms = base_start_ms + drand() * simtime_ms;
                    flows.push_back(Flow(master, client, bytes, start_time_ms));
		}
	    }
	  }
      }
  }
}


void ConnectionMatrix::setRacktoRackFlowsHardCoding(Topology *top, set<int>* sender_servers, set<int>* receiver_servers, int multiplier, int numerator, int denominator){
  cout<<"Rack to rack: " << endl;
  cout << "Senders: ";
  for (int s : *sender_servers) {
    cout << s << ",";
  }
  cout << endl;
  cout << "Receivers: ";
  for (int r : *receiver_servers) {
    cout << r << ",";
  }
  cout << endl;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;

  for (int inst=0; inst<10; inst++){
      // Have a gap of 10 sec between every instance
      double base_start_ms = 1 * 1000.0 * inst;

      for (int ii=0; ii<multiplier; ii++){
          for(int master: *sender_servers){
            for(int client: *receiver_servers){
                int bytes = genFlowBytes();
                // ignore flows > 100 MB
                while (bytes > 10 * 1024 * 1024){
                    bytes = genFlowBytes();
                }
                //bytes = 2 * 1024 * 1024;
                bytes = mss * ((bytes+mss-1)/mss);
                double simtime_ms = 49.0;
                double start_time_ms = base_start_ms + drand() * simtime_ms;
                flows.push_back(Flow(master, client, bytes, start_time_ms));
            }
          }
      }

      if (denominator > 0) {
          for(int master: *sender_servers){
            for(int client: *receiver_servers){
	            int should_add = rand()%denominator;
              if (should_add < numerator) {
                int bytes = genFlowBytes();
                // ignore flows > 100 MB
                while (bytes > 10 * 1024 * 1024){
                    bytes = genFlowBytes();
                }
                //bytes = 2 * 1024 * 1024;
                bytes = mss * ((bytes+mss-1)/mss);
                double simtime_ms = 49.0;
                double start_time_ms = base_start_ms + drand() * simtime_ms;
                flows.push_back(Flow(master, client, bytes, start_time_ms));
              }
            }
	        }
      }
  }
}


void ConnectionMatrix::setFewtoSomeFlows(Topology *top, int nmasters, int nclients, int multiplier, int numerator, int denominator, double simtime_ms){
  cout<<"Few to some: "<<nmasters<<" , "<<nclients<<endl;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
	  }
      maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  cout<<"Maxrackid: "<<maxrackid<<endl;
  bool* switch_covered = new bool[maxrackid];

  int _nmasters = nmasters, _nclients = nclients;
  for (int inst=0; inst<1; inst++){
      // Have a gap of 10 sec between every instance
      double base_start_ms = 1 * 1000.0 * inst;
      std::fill(switch_covered, switch_covered + maxrackid, false);
      nmasters = _nmasters;
      nclients = _nclients;

      vector<int> mastersvrs, clientsvrs;
      pair<vector<int>, vector<int> > chosenracks = top->getcsRacks(nmasters, nclients);

      int curr=0;
      cout<<"clientracks: ";
      while(nmasters>0){
        //int rack = rand()%maxrackid;
        //while(switch_covered[rack]) rack = rand()%maxrackid;
        int rack = chosenracks.first[curr++]; 
        cout<<rack<<",";
        switch_covered[rack] = true;
        for (int i=0;i<N && nmasters>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == rack){
                mastersvrs.push_back(i);
                nmasters--;
            }
        }
      }
      cout<<endl;
      curr=0;
      cout<<"serverracks: ";
      while(nclients>0){
        //int clientrack = rand()%maxrackid;
        //while(switch_covered[clientrack]) clientrack = rand()%maxrackid;
        int clientrack = chosenracks.second[curr++]; 
       cout<<clientrack<<",";
        switch_covered[clientrack] = true;
        for (int i=0;i<N && nclients>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == clientrack){
                clientsvrs.push_back(i);
                nclients--;
            }
        }
      }
      cout<<endl;
      // multiplier = multiplier/3;
      // multiplier = multiplier*3;
      for (int ii=0; ii<multiplier; ii++){
          for(int master: mastersvrs){
              for(int client: clientsvrs){
                  int bytes = genFlowBytes();
                  // ignore flows > 100 MB
                  while (bytes > 10 * 1024 * 1024){
                      bytes = genFlowBytes();
                  }
                  //bytes = 2 * 1024 * 1024;
                  bytes = mss * ((bytes+mss-1)/mss);
                  // bytes = bytes*3;
                  // bytes = bytes/3;
                  // AnnC: this part is completely hard coding; should change later
                  // double base_simtime_ms = 196.0;=
                  // double multiplier_simtime_ms = (_nmasters*_nclients) / (768.0*192.0);
                  // double simtime_ms = base_simtime_ms * multiplier_simtime_ms;
                  // cout << "multiplier_simtime_ms = " << multiplier_simtime_ms << ", simtime_ms = " << simtime_ms << endl;
                  // AnnC: end of hard coding
                  double start_time_ms = base_start_ms + drand() * simtime_ms;
                  flows.push_back(Flow(master, client, bytes, start_time_ms));
              }
          }
      }

      if (denominator > 0) {
          for(int master: mastersvrs){
            for(int client: clientsvrs){
	        int should_add = rand()%denominator;
		if (should_add < numerator) {
                    int bytes = genFlowBytes();
                    // ignore flows > 100 MB
                    while (bytes > 10 * 1024 * 1024){
                        bytes = genFlowBytes();
                    }
                    //bytes = 2 * 1024 * 1024;
                    bytes = mss * ((bytes+mss-1)/mss);
                    // double simtime_ms = 196.0;
                  // AnnC: this part is completely hard coding; should change later
                  // double base_simtime_ms = 196.0;
                  // double multiplier_simtime_ms = (_nmasters*_nclients) / (768.0*192.0);
                  // double simtime_ms = base_simtime_ms * multiplier_simtime_ms;
                  // cout << "multiplier_simtime_ms = " << multiplier_simtime_ms << ", simtime_ms = " << simtime_ms << endl;
                  // AnnC: end of hard coding
                    double start_time_ms = base_start_ms + drand() * simtime_ms;
                    flows.push_back(Flow(master, client, bytes, start_time_ms));
		}
	    }
	  }
      }
  }
}


void ConnectionMatrix::setFewtoSomeFlowsHardCoding(Topology *top, set<int>* sender_servers, set<int>* receiver_servers, int multiplier, int numerator, int denominator, double simtime_ms){
  cout<<"Few to some: " << endl;
  cout << "Senders: ";
  for (int s : *sender_servers) {
    cout << s << ",";
  }
  cout << endl;
  cout << "Receivers: ";
  for (int r : *receiver_servers) {
    cout << r << ",";
  }
  cout << endl;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;

  for (int inst=0; inst<1; inst++){
      // Have a gap of 10 sec between every instance
      double base_start_ms = 1 * 1000.0 * inst;

      for (int ii=0; ii<multiplier; ii++){
          for(int master: *sender_servers){
              for(int client: *receiver_servers){
                  int bytes = genFlowBytes();
                  // ignore flows > 100 MB
                  while (bytes > 10 * 1024 * 1024){
                      bytes = genFlowBytes();
                  }
                  //bytes = 2 * 1024 * 1024;
                  bytes = mss * ((bytes+mss-1)/mss);
                  // double simtime_ms = 196.0;
                  double start_time_ms = base_start_ms + drand() * simtime_ms;
                  flows.push_back(Flow(master, client, bytes, start_time_ms));
              }
          }
      }

      if (denominator > 0) {
          for(int master: *sender_servers){
            for(int client: *receiver_servers){
              int should_add = rand()%denominator;
              if (should_add < numerator) {
                int bytes = genFlowBytes();
                // ignore flows > 100 MB
                while (bytes > 10 * 1024 * 1024){
                    bytes = genFlowBytes();
                }
                //bytes = 2 * 1024 * 1024;
                bytes = mss * ((bytes+mss-1)/mss);
                // double simtime_ms = 196.0;
                double start_time_ms = base_start_ms + drand() * simtime_ms;
                flows.push_back(Flow(master, client, bytes, start_time_ms));
              }
	          }
	        }
      }
  }
}


void ConnectionMatrix::setMixFlows(Topology *top, int nracks, int multiplier, int numerator, int denominator){
  int nmasters = nracks * 48; // 4 racks, 48 servers per rack
  int nclients = nracks * 48;
  cout<<"Mix: "<<nmasters<<" , "<<nclients<<endl;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
	  }
      maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  cout<<"Maxrackid: "<<maxrackid<<endl;
  bool* switch_covered = new bool[maxrackid];

  int _nmasters = nmasters, _nclients = nclients;
  for (int inst=0; inst<1; inst++){
      // Have a gap of 10 sec between every instance
      double base_start_ms = 1 * 1000.0 * inst;
      std::fill(switch_covered, switch_covered + maxrackid, false);
      nmasters = _nmasters;
      nclients = _nclients;

      vector<int> mastersvrs, clientsvrs;
      pair<vector<int>, vector<int> > chosenracks = top->getcsRacks(nmasters, nclients);

      int curr=0;
      set<int> used_servers;
      cout<<"clientracks: ";
      while(nmasters>0){
        //int rack = rand()%maxrackid;
        //while(switch_covered[rack]) rack = rand()%maxrackid;
        int rack = chosenracks.first[curr++]; 
        cout<<rack<<",";
        switch_covered[rack] = true;
        for (int i=0;i<N && nmasters>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == rack){
                mastersvrs.push_back(i);
                used_servers.insert(i);
                nmasters--;
            }
        }
      }
      cout<<endl;
      curr=0;
      cout<<"serverracks: ";
      while(nclients>0){
        //int clientrack = rand()%maxrackid;
        //while(switch_covered[clientrack]) clientrack = rand()%maxrackid;
        int clientrack = chosenracks.second[curr++]; 
       cout<<clientrack<<",";
        switch_covered[clientrack] = true;
        for (int i=0;i<N && nclients>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == clientrack){
                clientsvrs.push_back(i);
                used_servers.insert(i);
                nclients--;
            }
        }
      }
      cout<<endl;
      // multiplier = multiplier/3;
      // multiplier = multiplier*3;
      for (int ii=0; ii<multiplier; ii++){
          for(int master: mastersvrs){
              for(int client: clientsvrs){
                  int bytes = genFlowBytes();
                  // ignore flows > 100 MB
                  while (bytes > 10 * 1024 * 1024){
                      bytes = genFlowBytes();
                  }
                  int bytes2 = genFlowBytes();
                  while (bytes2 > 10 * 1024 * 1024){
                      bytes2 = genFlowBytes();
                  }
                  //bytes = 2 * 1024 * 1024;
                  bytes = mss * ((bytes+mss-1)/mss);
                  bytes2 = mss * ((bytes2+mss-1)/mss);
                  // bytes = bytes*3;
                  // bytes = bytes/3;
                  double simtime_ms = nracks==4 ? 196.0 : 392.0;
                  double start_time_ms = base_start_ms + drand() * simtime_ms;
                  double start_time_ms2 = base_start_ms + drand() * simtime_ms;
                  flows.push_back(Flow(master, client, bytes, start_time_ms));
                  flows.push_back(Flow(client, master, bytes2, start_time_ms2));
              }
          }
      }

      if (denominator > 0) {
          for(int master: mastersvrs){
            for(int client: clientsvrs){
	        int should_add = rand()%denominator;
		if (should_add < numerator) {
                    int bytes = genFlowBytes();
                    // ignore flows > 100 MB
                    while (bytes > 10 * 1024 * 1024){
                        bytes = genFlowBytes();
                    }
                    //bytes = 2 * 1024 * 1024;
                    bytes = mss * ((bytes+mss-1)/mss);
                  int bytes2 = genFlowBytes();
                  while (bytes2 > 10 * 1024 * 1024){
                      bytes2 = genFlowBytes();
                  }
                    bytes2 = mss * ((bytes2+mss-1)/mss);
                    double simtime_ms = nracks==4 ? 196.0 : 392.0;
                    double start_time_ms = base_start_ms + drand() * simtime_ms;
                    double start_time_ms2 = base_start_ms + drand() * simtime_ms;
                    flows.push_back(Flow(master, client, bytes, start_time_ms));
                    flows.push_back(Flow(client, master, bytes2, start_time_ms2));
		}
	    }
	  }
      }

  int cnx = 0;
  if (denominator == 0) {
    cnx = _nmasters * _nclients * 2 * multiplier;
  } else {
    cnx = (int)(_nmasters * _nclients * 2 * (multiplier + (double)numerator/denominator));
  }
  cout<<"Num flows: "<<cnx << endl;
  for (int conn = 0;conn<cnx; conn++) {
    int src = rand()%N;
    while (used_servers.find(src) != used_servers.end()) {
      src = rand()%N;
    }
    int dest = rand()%N;
    while (used_servers.find(dest) != used_servers.end()) {
      dest = rand()%N;
    }
    int bytes = genFlowBytes();
    // ignore flows > 100 MB
    while (bytes > 10 * 1024 * 1024){
        bytes = genFlowBytes();
    }
    //bytes = 2 * 1024 * 1024;
    bytes = mss * ((bytes+mss-1)/mss);
    // bytes = bytes*3;
    // bytes = bytes/3;
    double simtime_ms = nracks==4 ? 196.0 : 392.0;
    double start_time_ms = drand() * simtime_ms;
    flows.push_back(Flow(src, dest, bytes, start_time_ms));
  }

  }
}

void ConnectionMatrix::setFluidMixFlows(Topology *top, vector<int>* hot_racks, int multiplier, int numerator, int denominator){
  cout<<"Fluid mix: ";
  for (int i=0; i<hot_racks->size(); i++) {
    cout << hot_racks->at(i) << " ";
  }
  cout << endl;
  // AnnC: this is hard-coding; can be more generic
  int numFlows = 150000;
  cout << "numFlows = " << numFlows;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;

  for (int inst=0; inst<1; inst++){
    // Have a gap of 10 sec between every instance
    double base_start_ms = 1 * 1000.0 * inst;

    set<int> hot_servers;
    for (int r=0; r<hot_racks->size(); r++) {
      int rack = hot_racks->at(r);
      for (int i=0;i<N;i++){
          int tor = top->ConvertHostToRack(i);
          if(tor == rack){
            hot_servers.insert(i);
          }
      }
    }

    int numActualFlows = denominator==0 ? numFlows*multiplier : (int)(numFlows * (numerator/(double)denominator)) + numFlows * multiplier;
    int numPartFlows = numActualFlows/2;
    // For among hot racks
    for (int conn = 0;conn<numPartFlows; conn++) {
      int src = rand()%N;
      while (hot_servers.find(src) == hot_servers.end()) {
        src = rand()%N;
      }
      int dest = rand()%N;
      while (hot_servers.find(dest) == hot_servers.end()) {
        dest = rand()%N;
      }
      int bytes = genFlowBytes();
      int mss = 1500;
      // ignore flows > 100 MB
      while (bytes > 10 * 1024 * 1024){
          bytes = genFlowBytes();
      }
      bytes = mss * ((bytes+mss-1)/mss);
      // AnnC: hard-coding
      double simtime_ms = 50.0;
      double start_time_ms = base_start_ms + drand() * simtime_ms;
      flows.push_back(Flow(src, dest, bytes, start_time_ms));
    }

    // For among non-hot racks
    for (int conn = 0;conn<numPartFlows; conn++) {
      int src = rand()%N;
      while (hot_servers.find(src) != hot_servers.end()) {
        src = rand()%N;
      }
      int dest = rand()%N;
      while (hot_servers.find(dest) != hot_servers.end()) {
        dest = rand()%N;
      }
      int bytes = genFlowBytes();
      int mss = 1500;
      // ignore flows > 100 MB
      while (bytes > 10 * 1024 * 1024){
          bytes = genFlowBytes();
      }
      bytes = mss * ((bytes+mss-1)/mss);
      // AnnC: hard-coding
      double simtime_ms = 50.0;
      double start_time_ms = base_start_ms + drand() * simtime_ms;
      flows.push_back(Flow(src, dest, bytes, start_time_ms));
    }
  }
}

void ConnectionMatrix::setFluidMixFlowsLeafspine(Topology *top, vector<int>* hot_servers, int multiplier, int numerator, int denominator){
  cout<<"Fluid mix: ";
  for (int i=0; i<hot_servers->size(); i++) {
    cout << hot_servers->at(i) << " ";
  }
  cout << endl;
  // AnnC: this is hard-coding; can be more generic
  int numFlows = 150000;
  cout << "numFlows = " << numFlows;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;

  for (int inst=0; inst<1; inst++){
    // Have a gap of 10 sec between every instance
    double base_start_ms = 1 * 1000.0 * inst;

    set<int> hot_servers_set (hot_servers->begin(), hot_servers->end());

    int numActualFlows = denominator==0 ? numFlows*multiplier : (int)(numFlows * (numerator/(double)denominator)) + numFlows * multiplier;
    int numPartFlows = numActualFlows/2;
    // For among hot racks
    for (int conn = 0;conn<numPartFlows; conn++) {
      int src = rand()%N;
      while (hot_servers_set.find(src) == hot_servers_set.end()) {
        src = rand()%N;
      }
      int dest = rand()%N;
      while (hot_servers_set.find(dest) == hot_servers_set.end()) {
        dest = rand()%N;
      }
      int bytes = genFlowBytes();
      int mss = 1500;
      // ignore flows > 100 MB
      while (bytes > 10 * 1024 * 1024){
          bytes = genFlowBytes();
      }
      bytes = mss * ((bytes+mss-1)/mss);
      // AnnC: hard-coding
      double simtime_ms = 50.0;
      double start_time_ms = base_start_ms + drand() * simtime_ms;
      flows.push_back(Flow(src, dest, bytes, start_time_ms));
    }

    // For among non-hot racks
    for (int conn = 0;conn<numPartFlows; conn++) {
      int src = rand()%N;
      while (hot_servers_set.find(src) != hot_servers_set.end()) {
        src = rand()%N;
      }
      int dest = rand()%N;
      while (hot_servers_set.find(dest) != hot_servers_set.end()) {
        dest = rand()%N;
      }
      int bytes = genFlowBytes();
      int mss = 1500;
      // ignore flows > 100 MB
      while (bytes > 10 * 1024 * 1024){
          bytes = genFlowBytes();
      }
      bytes = mss * ((bytes+mss-1)/mss);
      // AnnC: hard-coding
      double simtime_ms = 50.0;
      double start_time_ms = base_start_ms + drand() * simtime_ms;
      flows.push_back(Flow(src, dest, bytes, start_time_ms));
    }
  }
}

void ConnectionMatrix::setFewtoSomeFlowsRepeat(Topology *top, int nmasters, int nclients, int multiplier, int numerator, int denominator){
  cout<<"Few to some: "<<nmasters<<" , "<<nclients<<endl;
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
	  }
      maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  cout<<"Maxrackid: "<<maxrackid<<endl;
  bool* switch_covered = new bool[maxrackid];

  int _nmasters = nmasters, _nclients = nclients;
  for (int inst=0; inst<5; inst++){
      // Have a gap of 10 sec between every instance
      double base_start_ms = 1 * 1000.0 * inst;
      std::fill(switch_covered, switch_covered + maxrackid, false);
      nmasters = _nmasters;
      nclients = _nclients;

      vector<int> mastersvrs, clientsvrs;
      pair<vector<int>, vector<int> > chosenracks = top->getcsRacks(nmasters, nclients);

      int curr=0;
      cout<<"clientracks: ";
      while(nmasters>0){
        //int rack = rand()%maxrackid;
        //while(switch_covered[rack]) rack = rand()%maxrackid;
        int rack = chosenracks.first[curr++]; 
        cout<<rack<<",";
        switch_covered[rack] = true;
        for (int i=0;i<N && nmasters>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == rack){
                mastersvrs.push_back(i);
                nmasters--;
            }
        }
      }
      cout<<endl;
      curr=0;
      cout<<"serverracks: ";
      while(nclients>0){
        //int clientrack = rand()%maxrackid;
        //while(switch_covered[clientrack]) clientrack = rand()%maxrackid;
        int clientrack = chosenracks.second[curr++]; 
       cout<<clientrack<<",";
        switch_covered[clientrack] = true;
        for (int i=0;i<N && nclients>0;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == clientrack){
                clientsvrs.push_back(i);
                nclients--;
            }
        }
      }
      cout<<endl;
      // multiplier = multiplier/3;
      // multiplier = multiplier*3;
      for (int ii=0; ii<multiplier; ii++){
          for(int master: mastersvrs){
              for(int client: clientsvrs){
                  int bytes = genFlowBytes();
                  // ignore flows > 100 MB
                  while (bytes > 10 * 1024 * 1024){
                      bytes = genFlowBytes();
                  }
                  //bytes = 2 * 1024 * 1024;
                  bytes = mss * ((bytes+mss-1)/mss);
                  // bytes = bytes*3;
                  // bytes = bytes/3;
                  // double simtime_ms = 196.0;
                  // AnnC: this part is completely hard coding; should change later
                  double base_simtime_ms = 196.0;
                  double multiplier_simtime_ms = (_nmasters*_nclients) / (768.0*192.0);
                  double simtime_ms = base_simtime_ms * multiplier_simtime_ms;
                  cout << "multiplier_simtime_ms = " << multiplier_simtime_ms << ", simtime_ms = " << simtime_ms << endl;
                  // AnnC: end of hard coding
                  double start_time_ms = base_start_ms + drand() * simtime_ms;
                  flows.push_back(Flow(master, client, bytes, start_time_ms));
              }
          }
      }

      if (denominator > 0) {
          for(int master: mastersvrs){
            for(int client: clientsvrs){
	        int should_add = rand()%denominator;
		if (should_add < numerator) {
                    int bytes = genFlowBytes();
                    // ignore flows > 100 MB
                    while (bytes > 10 * 1024 * 1024){
                        bytes = genFlowBytes();
                    }
                    //bytes = 2 * 1024 * 1024;
                    bytes = mss * ((bytes+mss-1)/mss);
                    // double simtime_ms = 196.0;
                  // AnnC: this part is completely hard coding; should change later
                  double base_simtime_ms = 196.0;
                  double multiplier_simtime_ms = (_nmasters*_nclients) / (768.0*192.0);
                  double simtime_ms = base_simtime_ms * multiplier_simtime_ms;
                  cout << "multiplier_simtime_ms = " << multiplier_simtime_ms << ", simtime_ms = " << simtime_ms << endl;
                  // AnnC: end of hard coding
                    double start_time_ms = base_start_ms + drand() * simtime_ms;
                    flows.push_back(Flow(master, client, bytes, start_time_ms));
		}
	    }
	  }
      }
  }
}


int ConnectionMatrix::genFlowBytes(){
    double x = exp_distribution(generator);
    int bytes = scale * exp(x);
    // cout << "bytes " << bytes << endl;
    return bytes;
} 

void ConnectionMatrix::setAlltoFew(Topology *top, int nmasters){
  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
	  }
      maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  cout<<"Maxrackid: "<<maxrackid<<endl;
  double sample_prob=0.1;
  bool* switch_covered = new bool[maxrackid];
  std::fill(switch_covered, switch_covered + maxrackid, false);
  while(nmasters>0){
	int rack = rand()%maxrackid;
	while(switch_covered[rack]) rack = rand()%maxrackid;
  	for (int i=0;i<N && nmasters>0;i++){
    	int tor = top->ConvertHostToRack(i);
		if(tor == rack){
			if(connections[i] == NULL) connections[i] = new vector<int>();
  			for (int j=0;j<N;j++){
				if(i != j){
					double e=drand();
					if(e<=sample_prob) connections[i]->push_back(j);

				}
			}
			nmasters--;
		}
	}
	switch_covered[rack] = true;
  }
}





void ConnectionMatrix::setAlltoAll(Topology *top){
  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
		}
    maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  cout<<"Maxrackid: "<<maxrackid<<endl;
  bool* switch_covered = new bool[maxrackid];
  bool* switch_covered2 = new bool[maxrackid];
  std::fill(switch_covered, switch_covered + maxrackid, false);
  for (int i=0;i<N;i++){
    int src_tor = top->ConvertHostToRack(i);
    connections[i] = new vector<int>();
    if(switch_covered[src_tor]) continue;
    std::fill(switch_covered2, switch_covered2 + maxrackid, false);
    for (int j=0;j<N;j++){
      int dest_tor = top->ConvertHostToRack(j);
      //cout<<i<<" ;;;;; "<<j<<endl;
      if (i==j || switch_covered2[dest_tor]) continue;
      //switch_covered2[dest_tor] = true;
      connections[i]->push_back(j);
    }
    //switch_covered[src_tor] = true;
  }
}


void ConnectionMatrix::setRackLevelAllToAllFlowsHardCoding(int multiplier, double simtime_ms) {
  // cannot handle numerator and denominator for now
  cout<<"Rack level all-to-all" << endl;
  int num_racks_leafspine = 64; // even if the topology is rrg, we still go by leafspine
  int num_servers_per_rack_leafspine = 48;
  for (int sr=0; sr<num_racks_leafspine; sr++) {
    for (int dr=0; dr<num_racks_leafspine; dr++) {
      if (sr == dr) continue;

      for (int m=0; m<multiplier; m++) {
        int i = m % num_servers_per_rack_leafspine;
        int src = sr*num_servers_per_rack_leafspine + i;
        int dst = dr*num_servers_per_rack_leafspine + i;

        int bytes = genFlowBytes();
        int mss = 1500;
        while (bytes > 10 * 1024 * 1024){
          bytes = genFlowBytes();
        }
        bytes = mss * ((bytes+mss-1)/mss);

        double start_time_ms = drand() * simtime_ms;
        flows.push_back(Flow(src, dst, bytes, start_time_ms));
      }
    }
  }
}


void ConnectionMatrix::setRackLevelPermutationFlowsHardCoding(int multiplier, double simtime_ms) {
  // cannot handle numerator and denominator for now
  cout<<"Rack-level permutation" << endl;
  bool should_save_tm = false;
  int num_racks_leafspine = 64; // even if the topology is rrg, we still go by leafspine
  int num_servers_per_rack_leafspine = 48;

  int fromrack [num_racks_leafspine] = {};
  int torack [num_racks_leafspine] = {};
  for (int i=0; i<num_racks_leafspine; i++) {
    fromrack[i] = i;
    torack[i] = i;
  }
  bool should_reshuffle = true;
  while (should_reshuffle) {
    random_shuffle(fromrack, fromrack+num_racks_leafspine);
    random_shuffle(torack, torack+num_racks_leafspine);
    for (int i=0; i<num_racks_leafspine; i++) {
      if (fromrack[i] == torack[i]) break;
      should_reshuffle = false;
    }
  }  

  for (int i=0; i<num_racks_leafspine; i++) {
    int sr = fromrack[i];
    int dr = torack[i];

    for (int m=0; m<multiplier; m++) {
      for (int s=0; s<num_servers_per_rack_leafspine; s++) {
        for (int d=0; d<num_servers_per_rack_leafspine; d++) {
          int src = sr*num_servers_per_rack_leafspine + s;
          int dst = dr*num_servers_per_rack_leafspine + d;

          int bytes = genFlowBytes();
          int mss = 1500;
          while (bytes > 10 * 1024 * 1024){
            bytes = genFlowBytes();
          }
          bytes = mss * ((bytes+mss-1)/mss);

          double start_time_ms = drand() * simtime_ms;
          flows.push_back(Flow(src, dst, bytes, start_time_ms));
        }
      }
    }
  }

  if (should_save_tm) {
    string output_filename = "synthetictrafficfiles/permutation/generated_flows";
    ofstream outputFile(output_filename);
    for (Flow flow : flows) {
      outputFile << flow.src << " " << flow.dst << " " << flow.bytes << " " << flow.start_time_ms << "\n";
    }
    outputFile.close();
  }
}


void ConnectionMatrix::setRackLevel16To4FlowsHardCoding(int multiplier, double simtime_ms) {
  // cannot handle numerator and denominator for now
  cout<<"Rack-level 16-to-4" << endl;
  int num_racks_leafspine = 64; // even if the topology is rrg, we still go by leafspine
  int num_servers_per_rack_leafspine = 48;
  for (int m=0; m<multiplier; m++) {
    for (int sr=48; sr<64; sr++) {
      for (int i=0; i<num_servers_per_rack_leafspine; i++) {
        for (int dr=0; dr<4; dr++) {
          for (int j=0; j<num_servers_per_rack_leafspine; j++) {
            int src = sr*num_servers_per_rack_leafspine + i;
            int dst = dr*num_servers_per_rack_leafspine + j;

            int bytes = genFlowBytes();
            int mss = 1500;
            while (bytes > 10 * 1024 * 1024){
              bytes = genFlowBytes();
            }
            bytes = mss * ((bytes+mss-1)/mss);

            double start_time_ms = drand() * simtime_ms;
            flows.push_back(Flow(src, dst, bytes, start_time_ms));
          }
        }
      }
    }
  }
}


void ConnectionMatrix::setDRingRackLevel16To4FlowsHardCoding(int multiplier, double simtime_ms) {
  // cannot handle numerator and denominator for now
  cout<<"DRing Rack-level 16-to-4" << endl;
  int num_racks_leafspine = 64; // even if the topology is rrg, we still go by leafspine
  int num_servers_per_rack_leafspine = 48;
  for (int m=0; m<multiplier; m++) {
    for (int sr=24; sr<40; sr++) {
      for (int i=0; i<num_servers_per_rack_leafspine; i++) {
        for (int dr=0; dr<4; dr++) {
          for (int j=0; j<num_servers_per_rack_leafspine; j++) {
            int src = sr*num_servers_per_rack_leafspine + i;
            int dst = dr*num_servers_per_rack_leafspine + j;

            int bytes = genFlowBytes();
            int mss = 1500;
            while (bytes > 10 * 1024 * 1024){
              bytes = genFlowBytes();
            }
            bytes = mss * ((bytes+mss-1)/mss);

            double start_time_ms = drand() * simtime_ms;
            flows.push_back(Flow(src, dst, bytes, start_time_ms));
          }
        }
      }
    }
  }
}


void ConnectionMatrix::setRackLevelRackToRackFlowsHardCoding(int multiplier, double simtime_ms) {
  // cannot handle numerator and denominator for now
  cout<<"Rack-level rack-to-rack" << endl;
  int num_racks_leafspine = 64; // even if the topology is rrg, we still go by leafspine
  int num_servers_per_rack_leafspine = 48;
  for (int m=0; m<multiplier; m++) {
    int sr = 0;
    int dr = 25;
    for (int i=0; i<num_servers_per_rack_leafspine; i++) {
      for (int j=0; j<num_servers_per_rack_leafspine; j++) {
        int src = sr*num_servers_per_rack_leafspine + i;
        int dst = dr*num_servers_per_rack_leafspine + j;

        int bytes = genFlowBytes();
        int mss = 1500;
        while (bytes > 10 * 1024 * 1024){
          bytes = genFlowBytes();
        }
        bytes = mss * ((bytes+mss-1)/mss);

        double start_time_ms = drand() * simtime_ms;
        flows.push_back(Flow(src, dst, bytes, start_time_ms));
      }
    }
  }
}


void ConnectionMatrix::setUniform(int flowsPerHost){
	for(int i=0; i<N; i++){
    connections[i] = new vector<int>();
	 for(int f=0; f<flowsPerHost; f++){
		int dest;
		do{
			dest = rand()%N;
		}while(find(connections[i]->begin(), connections[i]->end(), dest) != connections[i]->end());
		connections[i]->push_back(dest);
	 }
	}
}



void ConnectionMatrix::setRackPermutation(Topology *top, int nRackFlows){
  vector<int> hosts, racks; 
  int maxrackid = -1;
  for(int i=0; i<N; i++){
     if(top->ConvertHostToRack(i) == -1){
        cout<<"ConvertHostToRack not implemented for topology"<<endl;
        abort();
	  }
     maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }
  int NRacks = maxrackid+1;
  cout<<"NRacks: "<<NRacks<<endl;
  int is_dest[NRacks],dest;
  fill(is_dest, is_dest+NRacks, 0);
  for (int src = 0; src < NRacks; src++) {
    cout<<"Finding pair for "<<src<<endl;
    int r = rand()%(NRacks-src);
    for (dest = 0;dest<NRacks;dest++){
      if (r==0&&!is_dest[dest])
       break;
      if (!is_dest[dest])
       r--;
    }
	 cout<<r<<" "<<dest<<endl;
    if (r!=0||is_dest[dest]){
      cout << "Wrong connections r " <<  r << "is_dest "<<is_dest[dest]<<endl;
      exit(1);
    }
    if (src==dest){
      //find first other destination that is different!
      do {
	   	dest = (dest+1)%NRacks;
      }
      while (is_dest[dest]);
      if (src==dest){
         printf("Wrong connections 2!\n");
	      exit(1);
      }
    }
    is_dest[dest] = 1;
	 vector<int> srcSvrs, destSvrs;
	 for(int svr=0; svr<N; svr++){
		int rack = top->ConvertHostToRack(svr);
		if(rack == src) srcSvrs.push_back(svr);
		if(rack == dest) destSvrs.push_back(svr);
	 }
	 int destInd=0;
	 for(int f=0; f<nRackFlows; f++){
	 	int srcSvr = 0, minSvrs=INT_MAX;
		for(int s: srcSvrs){
			if(connections[s] == NULL){
				srcSvr = s; 
				break;
			}
			else if(connections[s]->size() < minSvrs){
				srcSvr = s;
				minSvrs = connections[s]->size();
			}
		}
		int destSvr = destSvrs[destInd];
		if(connections[srcSvr] == NULL)
			connections[srcSvr] = new vector<int>();
		connections[srcSvr]->push_back(destSvr);
		destInd = (destInd+1)%destSvrs.size();
	 }
  }
}

void ConnectionMatrix::setRacktoRack(Topology *top, int nracks){
  vector<int> hosts, racks; 

  int maxrackid = -1;
  for(int i=0; i<N; i++){
	  if(top->ConvertHostToRack(i) == -1){
			cout<<"ConvertHostToRack not implemented for topology"<<endl;
			abort();
		}
    maxrackid = max(top->ConvertHostToRack(i), maxrackid);
  }

  for (int i=0; i<nracks; i++){
    int r;
    do {
      r = rand()%(maxrackid+1);
			//cout<<"Picking rack #"<<i<<", maxrackid:"<<maxrackid<<", candidate:"<<r<<endl;
		} while(find(racks.begin(), racks.end(), r) != racks.end()); 
		cout<<"Rack chosen: "<<r<<endl;
		racks.push_back(r);
  }

  bool done=false;
	for (int i=0; i<N; i++){
		int r = top->ConvertHostToRack(i);
		//cout<<"r: "<<r<<", N:"<<N<<endl;
		if((find(racks.begin(), racks.end(), r) != racks.end()) && (r!=racks[0] || !done )){
			hosts.push_back(i);
			if(r==racks[0]) done = true;
		}
	}
 
  int nconn = 0; 
  for (int i=0;i<hosts.size();i++){
    connections[hosts[i]] = new vector<int>();
    for (int j=0;j<hosts.size();j++){
      if (top->ConvertHostToRack(hosts[i])==top->ConvertHostToRack(hosts[j]))
        continue;
      connections[hosts[i]]->push_back(hosts[j]);
			nconn++;
    }
  }
  cout<<"Nconnections: "<<nconn<<endl;
}


void ConnectionMatrix::setFlowsFromFile(Topology* top, string filename, int multiplier, int numerator, int denominator) {
  int nflows = 0; 
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  //< read TM from file
  ifstream TMFile(filename.c_str());
  string line;
  line.clear();
  int currswitch=0;
  vector<Flow> temp_flows;
  if (TMFile.is_open()){
    while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int from, to, bytes;
        double start_time_ms;
        ss >> from >> to >> bytes >> start_time_ms;
        bytes = mss * ((bytes+mss-1)/mss);
        if (from >= N or to >= N) continue;
        if (multiplier > 0) {
            temp_flows.push_back(Flow(from, to, bytes, start_time_ms));
            nflows++;
        } else if (multiplier == 0) {
	    int should_add = rand()%denominator;
	    if (should_add < numerator) {
                temp_flows.push_back(Flow(from, to, bytes, start_time_ms));
                nflows++;
	    }
	}
    }
    TMFile.close();
  }
  flows = temp_flows;

  // adding more flows if multiplier > 1
  for (int ii=1; ii<multiplier; ii++) {
    for (int j=0; j<temp_flows.size(); j++) {
      Flow temp = temp_flows[j];
      flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
      nflows++;
    }
  }

  // adding more flows if denominator > 0
  if (multiplier > 0 && denominator > 0) {
    for (int j=0; j<temp_flows.size(); j++) {
      int should_add = rand()%denominator;
      if (should_add < numerator) {
        Flow temp = temp_flows[j];
        flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
        nflows++;
      }
    }
  }
  cout<<"Nflows: "<<nflows<<endl;
}

int getOneServerFromRack(int numservers, int numracks, int whichrack) {
  int quotient = numservers/numracks;
  int remainder = numservers%numracks;
  int startserver, numserversfromthisrack;
  if (whichrack < (numracks-remainder)) {
    startserver = quotient*whichrack;
    numserversfromthisrack = quotient;
  } else {
    startserver = quotient*whichrack+(whichrack-(numracks-remainder));
    numserversfromthisrack = quotient+1;
  }
  return rand()%numserversfromthisrack + startserver;
}

void ConnectionMatrix::setFlowsFromFileXHardCoding(Topology* top, string filename, int multiplier, int numerator, int denominator) {
  // Repurpose numerator and denominator as starttime and endtime for now
  int start_timeframe = numerator;
  int end_timeframe = denominator;
  numerator = 0;
  denominator = 0;
  int numservers = 3072;
  int numracks = 80;

  int nflows = 0; 
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  //< read TM from file
  ifstream TMFile(filename.c_str());
  string line;
  line.clear();
  int currswitch=0;
  vector<Flow> temp_flows;
  if (TMFile.is_open()){
    while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int fromrack, torack, bytes, start_time_s;
        ss >> start_time_s >> bytes >> fromrack >> torack;
        if (start_time_s < start_timeframe) continue;
        if (start_time_s >= end_timeframe) break; // the traffic data is sorted
        bytes = mss * ((bytes+mss-1)/mss);
        int fromserver = getOneServerFromRack(numservers, numracks, fromrack);
        int toserver = getOneServerFromRack(numservers, numracks, torack);
        double start_time_ms = ((start_time_s-start_timeframe+1)-(double)rand()/(double)RAND_MAX)/205.0;
        if (fromserver >= numservers or toserver >= numservers) continue;
        if (multiplier > 0) {
            temp_flows.push_back(Flow(fromserver, toserver, bytes, start_time_ms));
            nflows++;
        } else if (multiplier == 0) {
	    int should_add = rand()%denominator;
	    if (should_add < numerator) {
                temp_flows.push_back(Flow(fromserver, toserver, bytes, start_time_ms));
                nflows++;
	    }
	}
    }
    TMFile.close();
  }
  flows = temp_flows;

  // adding more flows if multiplier > 1
  for (int ii=1; ii<multiplier; ii++) {
    for (int j=0; j<temp_flows.size(); j++) {
      Flow temp = temp_flows[j];
      flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
      nflows++;
    }
  }

  // adding more flows if denominator > 0
  if (multiplier > 0 && denominator > 0) {
    for (int j=0; j<temp_flows.size(); j++) {
      int should_add = rand()%denominator;
      if (should_add < numerator) {
        Flow temp = temp_flows[j];
        flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
        nflows++;
      }
    }
  }
  cout<<"Nflows: "<<nflows<<endl;
}

int generateAdjustedBytes(int bytes, int mss) {
  return mss * ((bytes+mss-1)/mss);
}

void ConnectionMatrix::setFlowsFromClusterXHardCoding(Topology* top, string cluster, int multiplier, int numerator, int denominator, int solvestart, int solveend, double simtime_ms) {
  int start_timeframe = solvestart;
  int end_timeframe = solveend;
  bool should_save_tm = false;
  int nflows = 0; 
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  int numservers = NHOST;
  int numracks;
  #if CHOSEN_TOPO == LEAFSPINE
    numracks = 64;
  #elif CHOSEN_TOPO == RRG
    numracks = 80;
  #endif
  cout << "numservers=" << numservers << ", numracks=" << numracks << endl;
  double coefficient = 1;

  // collect all TM files
  if (cluster.compare("a") != 0 and cluster.compare("b") != 0 and cluster.compare("c") != 0) {
    cout << "An unknown cluster is indicated as input: " << cluster << endl;
    exit(0);
  }
  string TM_file_prefix = "trafficfiles/cluster_" + cluster + "/traffic_64racks";
  queue<string> TM_files;
  if (cluster.compare("a") == 0) {
    TM_files.push("_0_273");
  } else if (cluster.compare("b") == 0) {
    TM_files.push("_0_500");
    TM_files.push("_500_1000");
    TM_files.push("_1000_1500");
    TM_files.push("_1500_2000");
    TM_files.push("_2000_2500");
    TM_files.push("_2500_2900");
  } else if (cluster.compare("c") == 0) {
    TM_files.push("_0_273");
  }

  // read in traffic for each pair of racks
  uint64_t** traffic_per_rack_pair = new uint64_t*[numracks];
  for (int i=0; i<numracks; i++) {
    traffic_per_rack_pair[i] = new uint64_t[numracks];
    for (int j=0; j<numracks; j++) {
      traffic_per_rack_pair[i][j] = 0;
    }
  }
  
  while (!TM_files.empty()) {
    string TM_file = TM_files.front();
    TM_files.pop();
    string filename = TM_file_prefix + TM_file;
    ifstream TMFile(filename.c_str());
    string line;
    line.clear();
    if (TMFile.is_open()){
      while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int fromserver, toserver, fromrack, torack, start_time_s;
	uint64_t bytes;
        ss >> start_time_s >> bytes >> fromserver >> toserver;
        if (start_time_s < start_timeframe) continue;
        if (start_time_s >= end_timeframe) break; // the traffic data is sorted

        fromrack = top->ConvertHostToRack(fromserver);
        torack = top->ConvertHostToRack(toserver);

        traffic_per_rack_pair[fromrack][torack] += bytes;
      }
      TMFile.close();
    }
  }

  // scale traffic
  for (int i=0; i<numracks; i++) {
    for (int j=0; j<numracks; j++) {
      traffic_per_rack_pair[i][j] = uint64_t(traffic_per_rack_pair[i][j]*coefficient);
    }
  }

  uint64_t leftover_traffic_threshold = 0;
  vector<Flow> temp_flows;
  vector<Flow> original_flows;
  for (int i=0; i<numracks; i++) {
    for (int j=0; j<numracks; j++) {
      if (i==j) continue;
      if (traffic_per_rack_pair[i][j] == 0) continue;
      uint64_t traffic_cap = traffic_per_rack_pair[i][j];
      uint64_t traffic_till_now = 0;
      
      bool have_sufficient_flows = false;
      while (!have_sufficient_flows) {
        int bytes = genFlowBytes();
        // ignore flows > 100 MB
        while (bytes > 10 * 1024 * 1024){
            bytes = genFlowBytes();
        }
        
        if (traffic_till_now + bytes <= traffic_cap) {
          if (traffic_till_now + bytes == traffic_cap) {
            have_sufficient_flows = true;
          }
          traffic_till_now += bytes;
          double start_time_ms = drand() * simtime_ms;
          int fromserver = getOneServerFromRack(numservers, numracks, i);
          int toserver = getOneServerFromRack(numservers, numracks, j);
          int bytes_adjusted = generateAdjustedBytes(bytes,mss);
          temp_flows.push_back(Flow(fromserver, toserver, bytes_adjusted, start_time_ms));
          if (should_save_tm) {
            original_flows.push_back(Flow(fromserver, toserver, bytes, start_time_ms));
          }
          // nflows++;
        } else {
          have_sufficient_flows = true;
        }
      }

      if (traffic_cap - traffic_till_now >= leftover_traffic_threshold) {
        int bytes = traffic_cap - traffic_till_now;
        int bytes_adjusted = generateAdjustedBytes(bytes,mss);
        double start_time_ms = drand() * simtime_ms;
        int fromserver = getOneServerFromRack(numservers, numracks, i);
        int toserver = getOneServerFromRack(numservers, numracks, j);
        temp_flows.push_back(Flow(fromserver, toserver, bytes_adjusted, start_time_ms));
        if (should_save_tm) {
          original_flows.push_back(Flow(fromserver, toserver, bytes, start_time_ms));
        }
        // nflows++;
      }
    }
  }
  // flows = temp_flows;

  // output the flows for debugging purpose
  if (should_save_tm) {
    string output_filename = "synthetictrafficfiles/cluster_b/generated_flows_" + to_string(start_timeframe) + "_" + to_string(end_timeframe);
    ofstream outputFile(output_filename);
    for (Flow flow : original_flows) {
      outputFile << flow.src << " " << flow.dst << " " << flow.bytes << " " << flow.start_time_ms << "\n";
    }
    outputFile.close();
  }

  // add flows if multiplier > 0
  for (int ii=0; ii<multiplier; ii++) {
    for (int j=0; j<temp_flows.size(); j++) {
      Flow temp = temp_flows[j];
      flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
      nflows++;
    }
  }

  // add flows if denominator > 0
  if (denominator > 0) {
    for (int j=0; j<temp_flows.size(); j++) {
      int should_add = rand()%denominator;
      if (should_add < numerator) {
        Flow temp = temp_flows[j];
        flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
        nflows++;
      }
    }
  }
  cout<<"Nflows: "<<nflows<<endl;

  // manage pointers
  for (int i=0; i<numracks; i++) {
    delete [] traffic_per_rack_pair[i];
  }
  delete [] traffic_per_rack_pair;
}

void ConnectionMatrix::setFlowsFromClusterXSmallInterval(Topology* top, string cluster, int multiplier, int numerator, int denominator, int solvestart, int solveend, int solveinterval, double simtime_ms) {
  bool should_save_tm = false;
  int nflows = 0; 
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
  int numservers = NHOST;
  int numracks;
  #if CHOSEN_TOPO == LEAFSPINE
    numracks = 64;
  #elif CHOSEN_TOPO == RRG
    numracks = NSW;
  #endif
  cout << "numservers=" << numservers << ", numracks=" << numracks << endl;

  // collect all TM files
  if (cluster.compare("a") != 0 and cluster.compare("b") != 0 and cluster.compare("c") != 0) {
    cout << "An unknown cluster is indicated as input: " << cluster << endl;
    exit(0);
  }
  string TM_file_prefix = "trafficfiles/cluster_" + cluster + "/traffic_64racks";
  queue<string> TM_files;
  if (cluster.compare("a") == 0) {
    TM_files.push("_0_273");
  } else if (cluster.compare("b") == 0) {
    TM_files.push("_0_500");
    TM_files.push("_500_1000");
    TM_files.push("_1000_1500");
    TM_files.push("_1500_2000");
    TM_files.push("_2000_2500");
    TM_files.push("_2500_2900");
  } else if (cluster.compare("c") == 0) {
    TM_files.push("_0_273");
  }

  // read in traffic for each pair of racks
  int numintervals = (solveend-solvestart) / solveinterval;
  uint64_t*** traffic_per_rack_pair_per_interval = new uint64_t**[numintervals];
  for (int k=0; k<numintervals; k++) {
    traffic_per_rack_pair_per_interval[k] = new uint64_t*[numracks];
    for (int i=0; i<numracks; i++) {
      traffic_per_rack_pair_per_interval[k][i] = new uint64_t[numracks];
      for (int j=0; j<numracks; j++) {
        traffic_per_rack_pair_per_interval[k][i][j] = 0;
      }
    }
  }
  
  while (!TM_files.empty()) {
    string TM_file = TM_files.front();
    TM_files.pop();
    string filename = TM_file_prefix + TM_file;
    ifstream TMFile(filename.c_str());
    string line;
    line.clear();
    if (TMFile.is_open()){
      while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int fromserver, toserver, fromrack, torack, start_time_s;
	      uint64_t bytes;
        ss >> start_time_s >> bytes >> fromserver >> toserver;
        if (start_time_s < solvestart) continue;
        if (start_time_s >= solveend) break; // the traffic data is sorted

        fromrack = top->ConvertHostToRack(fromserver);
        torack = top->ConvertHostToRack(toserver);
        int whichinterval = (start_time_s-solvestart) / solveinterval;

        traffic_per_rack_pair_per_interval[whichinterval][fromrack][torack] += bytes;
      }
      TMFile.close();
    }
  }

  double simtime_per_interval_ms = simtime_ms / numintervals;
  vector<Flow> temp_flows;
  vector<Flow> original_flows;
  for (int k=0; k<numintervals; k++) {
    for (int i=0; i<numracks; i++) {
      for (int j=0; j<numracks; j++) {
        if (i==j) {
          traffic_per_rack_pair_per_interval[k][i][j] = 0;
          continue;
        }
        if (traffic_per_rack_pair_per_interval[k][i][j] == 0) continue;

        uint64_t total_traffic = traffic_per_rack_pair_per_interval[k][i][j];
        uint64_t traffic_till_now = 0;
        bool have_sufficient_flows = false;
        while (!have_sufficient_flows) {
          int bytes = genFlowBytes();
          while (bytes > 10 * 1024 * 1024){
              bytes = genFlowBytes();
          }
          
          if (traffic_till_now + bytes > total_traffic) {
            have_sufficient_flows = true;
            bytes = total_traffic - traffic_till_now;
          } else if (traffic_till_now + bytes == total_traffic) {
            have_sufficient_flows = true;
          } else {
            // Do nothing
          }
          
          traffic_till_now += bytes;
          int bytes_adjusted = mss * ((bytes+mss-1)/mss);
          double start_time_ms = drand() * simtime_per_interval_ms + k*simtime_per_interval_ms;
          int fromserver = getOneServerFromRack(numservers, numracks, i);
          int toserver = getOneServerFromRack(numservers, numracks, j);
          
          temp_flows.push_back(Flow(fromserver, toserver, bytes_adjusted, start_time_ms));
          if (should_save_tm) {
            original_flows.push_back(Flow(fromserver, toserver, bytes, start_time_ms));
          }
        }
      }
    }
  }
  // flows = temp_flows;

  // output the flows for debugging purpose
  if (should_save_tm) {
    string output_filename = "synthetictrafficfiles/cluster_b/generated_flows_" + to_string(solvestart) + "_" + to_string(solveend);
    ofstream outputFile(output_filename);
    for (Flow flow : original_flows) {
      outputFile << flow.src << " " << flow.dst << " " << flow.bytes << " " << flow.start_time_ms << "\n";
    }
    outputFile.close();
  }

  // add flows if multiplier > 0
  for (int ii=0; ii<multiplier; ii++) {
    for (int j=0; j<temp_flows.size(); j++) {
      Flow temp = temp_flows[j];
      flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
      nflows++;
    }
  }

  // add flows if denominator > 0
  if (denominator > 0) {
    for (int j=0; j<temp_flows.size(); j++) {
      int should_add = rand()%denominator;
      if (should_add < numerator) {
        Flow temp = temp_flows[j];
        flows.push_back(Flow(temp.src, temp.dst, temp.bytes, temp.start_time_ms));
        nflows++;
      }
    }
  }
  cout<<"Nflows: "<<nflows<<endl;

  // manage pointers
  for (int k=0; k<numintervals; k++) {
    for (int i=0; i<numracks; i++) {
      delete [] traffic_per_rack_pair_per_interval[k][i];
    }
    delete [] traffic_per_rack_pair_per_interval[k];
  }
  delete [] traffic_per_rack_pair_per_interval;
}


void ConnectionMatrix::setFlowsFromClusterYHardCoding(Topology* top, string cluster, int multiplier, int numerator, int denominator, double simtime_ms) {
  int nflows = 0; 
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;

  // collect all TM files
  if (cluster.compare("a") != 0 and cluster.compare("b") != 0 and cluster.compare("c") != 0) {
    cout << "An unknown cluster is indicated as input: " << cluster << endl;
    exit(0);
  }
  string TM_file_prefix = "trafficfiles/cluster_" + cluster + "/traffic_64racks";
  queue<string> TM_files;
  int downscale_traffic;
  int upscale_bytes;
  if (cluster.compare("a") == 0) {
    TM_files.push("_0_273");
    downscale_traffic = 20;
    upscale_bytes = 40;
  } else if (cluster.compare("b") == 0) {
    TM_files.push("_0_500");
    TM_files.push("_500_1000");
    TM_files.push("_1000_1500");
    TM_files.push("_1500_2000");
    TM_files.push("_2000_2500");
    TM_files.push("_2500_2900");
    downscale_traffic = 250;
    upscale_bytes = 15;
  } else if (cluster.compare("c") == 0) {
    TM_files.push("_0_273");
    downscale_traffic = 25;
    upscale_bytes = 2;
  }

  if (denominator == 0 and numerator == 0) {
    numerator = multiplier;
    denominator = downscale_traffic;
  } else {
    numerator = multiplier * denominator + numerator;
    denominator = denominator * downscale_traffic;
  }
  assert(numerator < denominator);
  multiplier = 0;

  vector<Flow> temp_flows;
  while (!TM_files.empty()) {
    string TM_file = TM_files.front();
    TM_files.pop();
    string filename = TM_file_prefix + TM_file;
    ifstream TMFile(filename.c_str());
    string line;
    line.clear();
    int currswitch=0;
    if (TMFile.is_open()){
      cout << "reading " << filename << endl;
      while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int fromserver, toserver, bytes, start_time_s;
        ss >> start_time_s >> bytes >> fromserver >> toserver;
        bytes = bytes*upscale_bytes;
        bytes = mss * ((bytes+mss-1)/mss);
        if (fromserver >= NHOST or toserver >= NHOST) continue;
        double start_time_ms = (start_time_s+drand())/86400.0*simtime_ms;
        if (multiplier == 0) {
          int should_add = rand()%denominator;
          if (should_add < numerator) {
            temp_flows.push_back(Flow(fromserver, toserver, bytes, start_time_ms));
            nflows++;
          }
        }
      }
      TMFile.close();
    }
  }
  flows = temp_flows;
  cout<<"Nflows: "<<nflows<<endl;
}


void ConnectionMatrix::setTrafficFromFile(Topology* top, string filename){
  int nconn = 0; 
  //< read TM from file
  ifstream TMFile(filename.c_str());
  string line;
  line.clear();
  int currswitch=0;
  if (TMFile.is_open()){
    while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int from, to;
        ss >> from >> to;
        if (from >= N or to >= N) continue;
        if (connections.find(from) == connections.end())
            connections[from] = new vector<int>();
        connections[from]->push_back(to);
        nconn++;
    }
    TMFile.close();
  }
  cout<<"Nconnections: "<<nconn<<endl;
}


void ConnectionMatrix::setTrafficFromFile2(Topology* top, string filename){
 
  int nconn = 0; 
  //< read TM from file
  ifstream TMFile(filename.c_str());
  string line;
  line.clear();
  int currswitch=0;
  if (TMFile.is_open()){
    while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;

        stringstream ss(line);

        int from, to, nflows;
        ss >> from >> to >> nflows;

        /*
        int from = atoi(line.substr(0, line.find(" ")).c_str());
        int to = atoi(line.substr(line.find(" ") + 1).c_str());
        int pos = line.find(" ") + 1;
        string tstr = line.substr(line.find(" ", pos) + 1).c_str();
        int nflows = atoi(line.substr(line.find(" ", pos) + 1).c_str());

        /***
        assert(from < N && to < N);
        if(connections.find(from) == connections.end())
           connections[from] = new vector<int>();
        connections[from]->push_back(to);
        nconn++;
        }
        ***/

        vector<int> from_servers, to_servers;
        vector<pair<int, int> > flow_pairs;

        float wt_down = 0.0001;
        nflows = wt_down * nflows;
        cout << from << " " << to << " " << nflows << endl;
        for (int i=0;i<N;i++){
            int tor = top->ConvertHostToRack(i);
            if(tor == from) from_servers.push_back(i);
            if(tor == to) to_servers.push_back(i);
        }
        for (int s: from_servers){
            for (int t: to_servers){
                if (s!=t) flow_pairs.push_back(pair<int, int>(s, t));
            }
        }
        if (flow_pairs.size() < nflows){
            cout << "Too many flows for rack pair " << nflows << endl;
            exit(0);
        }
        std::random_shuffle(flow_pairs.begin(),flow_pairs.end());
        for (int i=0; i<nflows; i++){
            if (connections.find(flow_pairs[i].first) == connections.end())
                connections[flow_pairs[i].first] = new vector<int>();
            connections[flow_pairs[i].first]->push_back(to);
            nconn++;
        }
    }
    TMFile.close();
  }
  cout<<"Nconnections: "<<nconn<<endl;
}



void ConnectionMatrix::setHotspot(int hosts_per_hotspot, int count){
  int is_dest[N],is_done[N];
  for (int i=0;i<N;i++){
    is_dest[i] = 0;
    is_done[i] = 0;
  }

  int first, src;
  for (int k=0;k<count;k++){
    do {
      first = rand()%N;
    }
    while (is_dest[first]);
    
    is_dest[first] = 1;
    
    for (int i=0;i<hosts_per_hotspot;i++){
      do{
	if (hosts_per_hotspot==N)
	  src = i;
	else
	  src = rand()%N;
      }
      while(is_done[src]);
      is_done[src]=1;

      if (connections.find(src)==connections.end())      
	connections[src] = new vector<int>();

      connections[src]->push_back(first);
      is_done[src] = 1;
    }  
  }
}


void ConnectionMatrix::setMaxWeightMatching(Topology *top){

	string pid = std::to_string(getpid());
	string serverDistFile = "serverDist/serverDist1_" + pid + ".txt";
	string maxMatchingFile = "serverDist/maxWeightMatch_" + pid + ".txt";
	top->printServerDistance(serverDistFile, N);
	string cmd = "python maxWeight.py " + serverDistFile + " " + maxMatchingFile;
	system(cmd.c_str());

	//< read TM from the maxMatchingFile
	ifstream myfile(maxMatchingFile.c_str());
	string line;
	if (myfile.is_open()){
		while(myfile.good()){
			getline(myfile, line);
			if (line.find(" ") == string::npos) break;
			int from = atoi(line.substr(0, line.find(" ")).c_str());
			int to = atoi(line.substr(line.find(" ") + 1).c_str());
			if(from >= N || to >= N){
				cout<<"Max Weight file has out of bounds nodes, "<<from<<"->"<<to<<", NSVR: "<<N<<endl;
				exit(0);
			}
			cout<<"(from, to, N): "<<from<<", "<<to<<", "<<N<<endl;
			if (connections.find(from)==connections.end())      
				connections[from] = new vector<int>();
			connections[from]->push_back(to);
		}
		myfile.close();
	}
	//>
}

set<pair<int, int> > ConnectionMatrix::addExtraConns(int num){
	//srand (time(NULL));
	set<pair<int, int> > extraConns;
	for(int i=0; i<num; i++){
		int src, dest; 
		do{
			src = rand()%N;
			dest = rand()%N;
		}
		while(src==dest || (connections.find(src) != connections.end() && find(connections[src]->begin(),connections[src]->end(),dest) != connections[src]->end()));
		if (connections.find(src)==connections.end())      
			connections[src] = new vector<int>();
		connections[src]->push_back(dest);
		extraConns.insert(pair<int, int>(src, dest));
	}
	return extraConns;
}

void ConnectionMatrix::setTestRandomFlows(double simtime_ms){
  int cnx = 50;
  cout<<"Num flows: "<<cnx << endl;
  for (int conn = 0;conn<cnx; conn++) {
    int src = rand()%N;
    int dest = rand()%N;
    int bytes = genFlowBytes();
    int mss = 1500;
    // ignore flows > 100 MB
    while (bytes > 10 * 1024 * 1024){
        bytes = genFlowBytes();
    }
    //bytes = 2 * 1024 * 1024;
    bytes = mss * ((bytes+mss-1)/mss);
    // bytes = bytes*3;
    // bytes = bytes/3;
    // double simtime_ms = 0.05;
    double start_time_ms = drand() * simtime_ms;
    flows.push_back(Flow(src, dest, bytes, start_time_ms));
  }
}

// void ConnectionMatrix::sortFlowsByStartTime() {
//   sorted_flows = flows;
//   sort(sorted_flows.begin(), sorted_flows.end(), compareFlow);
// }

int ConnectionMatrix::determineNumFlowsThreshold(double measurement_start_ms, double measurement_end_ms) {
  int num_flows = 0;
  for (Flow& flow: flows){
    if (flow.start_time_ms >= measurement_start_ms && flow.start_time_ms < measurement_end_ms) {
      num_flows++;
    }
  }
  return num_flows;
}

/*
void ConnectionMatrix::setHotspot(int hosts){
  int is_dest[N],dest,is_done[N];
  for (int i=0;i<N;i++){
    is_dest[i] = 0;
    is_done[i] = 0;
  }

  int first = rand()%N;
  is_done[first] = 1;
  is_dest[first] = 1;

  for (int i=0;i<hosts-1;i++){
    int src;
    do{
      src = rand()%N;
    }
    while(is_done[src]);
    is_done[src]=1;
    connections[src] = new vector<int>();
    connections[src]->push_back(first);
    //is_dest[src] = 1;
  }  

  for (int src = 0; src < N; src++) {
    if (is_done[src])
      continue;

    vector<int>* destinations = new vector<int>();
      
    int r = rand()%(N-src);
    for (dest = 0;dest<N;dest++){
      if (r==0&&!is_dest[dest])
	break;
      if (!is_dest[dest])
	r--;
    }

    if (r!=0||is_dest[dest]){
      cout << "Wrong connections r " <<  r << "is_dest "<<is_dest[dest]<<endl;
      exit(1);
    }
      
    if (src==dest){
      //find first other destination that is different!
      do {
	dest = (dest+1)%N;
      }
      while (is_dest[dest]);
	
      if (src==dest){
	printf("Wrong connections 2!\n");
	exit(1);
      }
    }
    is_dest[dest] = 1;
    destinations->push_back(dest);

    connections[src] = destinations;    
  }
}
*/


int ConnectionMatrix::adjustBytesByPacketSize(int bytes) {
  int mss = Packet::data_packet_size();
  if (bytes >= large_flow_threshold+mss) {
    cout << "***Error adjustBytesByPacketSize: bytes too large, bytes=" << bytes << endl;
    exit(1);
  }
  if (bytes<0) {
    cout << "***Error adjustBytesByPacketSize: bytes<0, bytes=" << bytes << endl;
    exit(1);
  }
  return mss * ((bytes+mss-1)/mss);
  return mss * ((bytes+mss-1)/mss);
}


void ConnectionMatrix::multiplyFlows(int multiplier, int numerator, int denominator) {
  if (numerator>denominator) {
    cout << "***Error multiplyFlows: numerator>denominator, numerator=" << numerator << ", denominator=" << denominator << endl;
    exit(1);
  }
  
  if (multiplier>0) {
    for (int m=0; m<multiplier; m++) {
      for (Flow& flow: base_flows) {
        flows.push_back(Flow(flow.src, flow.dst, flow.bytes, flow.start_time_ms));
      }
    }
  }

  if (denominator>0) {
    for (Flow& flow: base_flows) {
      int should_add = rand()%denominator;
      if (should_add<numerator) {
        flows.push_back(Flow(flow.src, flow.dst, flow.bytes, flow.start_time_ms));
      }
    }
  }
}


void ConnectionMatrix::setTopoFlowsAllToAll(double simtime_ms) {
  cout<<"Topo flows all to all" << endl;
  for (int srcsvr=0; srcsvr<NHOST; srcsvr++) {
    for (int dstsvr=0; dstsvr<NHOST; dstsvr++) {
      if (srcsvr==dstsvr) continue;
      int bytes = genFlowBytes();
      while (bytes<0 or bytes>large_flow_threshold){
        bytes = genFlowBytes();
      }
      bytes = adjustBytesByPacketSize(bytes);
      double start_time_ms = drand() * simtime_ms;
      base_flows.push_back(Flow(srcsvr, dstsvr, bytes, start_time_ms));
    }
  }
}


void ConnectionMatrix::setTopoFlowsClusterX(Topology* top, string cluster, int solvestart, int solveend, int solveinterval, double simtime_ms) {
  cout << "Topo flows clusterX" << endl;
  int numservers = NHOST;
  int numracks;
  #if CHOSEN_TOPO == LEAFSPINE
    numracks = NL;
  #elif CHOSEN_TOPO == RRG
    numracks = NSW;
  #endif
  cout << "numservers=" << numservers << ", numracks=" << numracks << endl;

  // collect all TM files
  if (cluster.compare("a") != 0 and cluster.compare("b") != 0 and cluster.compare("c") != 0) {
    cout << "An unknown cluster is indicated as input: " << cluster << endl;
    exit(0);
  }
  string TM_file_prefix = "trafficfiles/cluster_" + cluster + "/traffic_64racks";
  queue<string> TM_files;
  if (cluster.compare("a") == 0 or cluster.compare("c") == 0) {
    TM_files.push("_0_273");
  } else if (cluster.compare("b") == 0) {
    TM_files.push("_0_500");
    TM_files.push("_500_1000");
    TM_files.push("_1000_1500");
    TM_files.push("_1500_2000");
    TM_files.push("_2000_2500");
    TM_files.push("_2500_2900");
  }

  // read in traffic for each pair of racks
  int numintervals = (solveend-solvestart) / solveinterval;
  uint64_t*** traffic_per_rack_pair_per_interval = new uint64_t**[numintervals];
  for (int k=0; k<numintervals; k++) {
    traffic_per_rack_pair_per_interval[k] = new uint64_t*[numracks];
    for (int i=0; i<numracks; i++) {
      traffic_per_rack_pair_per_interval[k][i] = new uint64_t[numracks];
      for (int j=0; j<numracks; j++) {
        traffic_per_rack_pair_per_interval[k][i][j] = 0;
      }
    }
  }
  
  while (!TM_files.empty()) {
    string TM_file = TM_files.front();
    TM_files.pop();
    string filename = TM_file_prefix + TM_file;
    ifstream TMFile(filename.c_str());
    string line;
    line.clear();
    if (TMFile.is_open()){
      while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int fromserver, toserver, fromrack, torack, start_time_s;
	      uint64_t bytes;
        ss >> start_time_s >> bytes >> fromserver >> toserver;
        if (start_time_s < solvestart) continue;
        if (start_time_s >= solveend) break; // the traffic data is sorted

        fromrack = top->ConvertHostToRack(fromserver);
        torack = top->ConvertHostToRack(toserver);
        int whichinterval = (start_time_s-solvestart) / solveinterval;

        traffic_per_rack_pair_per_interval[whichinterval][fromrack][torack] += bytes;
      }
      TMFile.close();
    }
  }

  double simtime_per_interval_ms = simtime_ms / numintervals;
  for (int k=0; k<numintervals; k++) {
    for (int i=0; i<numracks; i++) {
      for (int j=0; j<numracks; j++) {
        if (i==j) {
          traffic_per_rack_pair_per_interval[k][i][j] = 0;
          continue;
        }
        if (traffic_per_rack_pair_per_interval[k][i][j] == 0) continue;

        uint64_t total_traffic = traffic_per_rack_pair_per_interval[k][i][j];
        uint64_t traffic_till_now = 0;
        bool have_sufficient_flows = false;
        while (!have_sufficient_flows) {
          int bytes = genFlowBytes();
          while (bytes<0 or bytes > large_flow_threshold){
              bytes = genFlowBytes();
          }
          
          if (traffic_till_now + bytes > total_traffic) {
            have_sufficient_flows = true;
            bytes = total_traffic - traffic_till_now;
          } else if (traffic_till_now + bytes == total_traffic) {
            have_sufficient_flows = true;
          }
          
          traffic_till_now += bytes;
          bytes = adjustBytesByPacketSize(bytes);
          double start_time_ms = drand() * simtime_per_interval_ms + k*simtime_per_interval_ms;
          int fromserver = getOneServerFromRack(numservers, numracks, i);
          int toserver = getOneServerFromRack(numservers, numracks, j);
          
          base_flows.push_back(Flow(fromserver, toserver, bytes, start_time_ms));
        }
      }
    }
  }

  // manage pointers
  for (int k=0; k<numintervals; k++) {
    for (int i=0; i<numracks; i++) {
      delete [] traffic_per_rack_pair_per_interval[k][i];
    }
    delete [] traffic_per_rack_pair_per_interval[k];
  }
  delete [] traffic_per_rack_pair_per_interval;
}


void ConnectionMatrix::setTopoFlowsSomeToSome(string conn_matrix_str, double simtime_ms) {
  cout << "Topo flows some to some" << endl;

  // Parse conn_matrix_str
  string delimiter = "_";
  size_t position = 0;
  size_t count = 0;
  string token;
  int numsendingracks,numreceivingracks,isbidirectionaltraffic,configfilenumber;
  while ((position = conn_matrix_str.find(delimiter)) != string::npos) {
    token = conn_matrix_str.substr(0, position);
    switch (count) {
      case 0:
        // pass
        break;
      case 1:
        numsendingracks = stoi(token);
        break;
      case 2:
        numreceivingracks = stoi(token);
        break;
      case 3:
        isbidirectionaltraffic = stoi(token);
        break;
      default:
        break;
    }
    conn_matrix_str.erase(0, position+delimiter.length());
    count++;
  }
  configfilenumber = stoi(conn_matrix_str);
  cout << "numsendingracks=" << numsendingracks << ",numreceivingracks=" << numreceivingracks << ",isbidirectionaltraffic=" << isbidirectionaltraffic << ",configfilenumber=" << configfilenumber << endl;

  // Read traffic from config file
  string trafficfilename = "trafficfiles/s2s_"+numsendingracks+"_"+numreceivingracks+"/"+configfilenumber+".txt";
  cout << "trafficfilename: " << trafficfilename << endl;
  ifstream TMFile(trafficfilename.c_str());
  string line, token;
  int racknumber;
  bool is_sending_racks = false, is_receiving_racks = false;
  vector<int> sending_racks;
  vector<int> receiving_racks;
  line.clear();
  if (TMFile.is_open()){
    while(TMFile.good()){
      getline(TMFile, line);
      //Whitespace line
      if (line.find_first_not_of(' ') == string::npos) break;
      stringstream ss(line);

      ss >> token;
      if (token == "sending") {
        is_sending_racks = true;
      } else if (token == "receiving") {
        is_receiving_racks = true;
        is_sending_racks = false;
      } else {
        racknumber = stoi(token);
        if (is_sending_racks) {
          sending_racks.push_back(racknumber);
        }
        if (is_receiving_racks) {
          receiving_racks.push_back(racknumber);
        }
      }
    }
    TMFile.close();
  }
  cout << "sending_racks:";
  for (int rack : sending_racks) {
    cout << " " << rack;
  }
  cout << endl;
  cout << "receiving_racks:";
  for (int rack : receiving_racks) {
    cout << " " << rack;
  }
  cout << endl;

  // Generate flows
  // AnnC: lsservers is hard-coded; should find a way to circumvent this
  int lsservers = 48; // number of servers per rack in leafspine
  cout << "lsservers=" << lsservers << endl;
  for (int srcrack : sending_racks) { 
    for (int dstrack : receiving_racks) {
      for (int srcsvr=srcrack*lsservers; srcsvr<(srcrack+1)*lsservers; srcsvr++) {
        for (int dstsvr=dstrack*lsservers; dstsvr<(dstrack+1)*lsservers; dstsvr++) {
          int bytes = genFlowBytes();
          while (bytes<0 or bytes>large_flow_threshold){
            bytes = genFlowBytes();
          }
          bytes = adjustBytesByPacketSize(bytes);
          double start_time_ms = drand() * simtime_ms;
          base_flows.push_back(Flow(srcsvr, dstsvr, bytes, start_time_ms));
        }
      } 
    }
  }

  if (isbidirectionaltraffic == 1) {
    cout << "bi-directional traffic" << endl;
    for (int srcrack : receiving_racks) {
      for (int dstrack : sending_racks) {
        for (int srcsvr=srcrack*lsservers; srcsvr<(srcrack+1)*lsservers; srcsvr++) {
          for (int dstsvr=dstrack*lsservers; dstsvr<(dstrack+1)*lsservers; dstsvr++) {
            int bytes = genFlowBytes();
            while (bytes<0 or bytes>large_flow_threshold){
              bytes = genFlowBytes();
            }
            bytes = adjustBytesByPacketSize(bytes);
            double start_time_ms = drand() * simtime_ms;
            base_flows.push_back(Flow(srcsvr, dstsvr, bytes, start_time_ms));
          }
        } 
      }
    }
  }
}


void ConnectionMatrix::printTopoFlows(Topology *top, string topoflowsfilename) {
  int numflows=0;
  int minstart=10000000;
  int maxstart=-1;

#if CHOSEN_TOPO == LEAFSPINE
  int maxrack=NL;
#elif CHOSEN_TOPO == RRG
  int maxrack=NSW;
#endif

  int64_t trafficmatrix[maxrack][maxrack];
  for (int i=0; i<maxrack; i++) {
    for (int j=0; j<maxrack; j++) {
      trafficmatrix[i][j]=0;
    }
  }

  int srcsw, dstsw;
  for (Flow& flow: flows) {
    srcsw = top->ConvertHostToRack(flow.src);
    dstsw = top->ConvertHostToRack(flow.dst);
    trafficmatrix[srcsw][dstsw] += flow.bytes;
    numflows++;
    if (flow.start_time_ms>maxstart) maxstart = flow.start_time_ms;
    if (flow.start_time_ms<minstart) minstart = flow.start_time_ms;
  }

  ofstream outputFile(topoflowsfilename);
  outputFile << "numflows=" << numflows << "\n";
  outputFile << "minstart=" << minstart << "\n";
  outputFile << "maxstart=" << maxstart << "\n";
  outputFile << "\n";

  for (int i=maxrack-1; i>=0; i--) {
    outputFile << i << "\t";
    for (int j=0; j<maxrack; j++) {
      outputFile << trafficmatrix[i][j] << "\t";
    }
    outputFile << "\n";
  }
  outputFile << "\t";
  for (int j=0; j<maxrack; j++) {
    outputFile << j << "\t";
  }
  outputFile << "\n";
  outputFile.close();
}
