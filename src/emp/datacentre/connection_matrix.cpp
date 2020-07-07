#include "connection_matrix.h"
#include <string.h>
#include <iostream>
#include <algorithm>
#include <sys/types.h>
#include <unistd.h>
#include <limits.h>
#include <fstream>
#include "tcppacket.h"
#include <bits/stdc++.h> 
#include <math.h>
#include <random>
#include <iostream>

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

void ConnectionMatrix::setRandomFlows(int cnx){
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
    double simtime_ms = 50.0;
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



void ConnectionMatrix::setRacktoRackFlows(Topology *top, int nmasters, int nclients){
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
  for (int inst=0; inst<50; inst++){
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
      for (int ii=0; ii<4; ii++){
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
  }
}


void ConnectionMatrix::setFewtoSomeFlows(Topology *top, int nmasters, int nclients){
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
      for (int ii=0; ii<1; ii++){
          for(int master: mastersvrs){
              for(int client: clientsvrs){
                  int bytes = genFlowBytes();
                  // ignore flows > 100 MB
                  while (bytes > 10 * 1024 * 1024){
                      bytes = genFlowBytes();
                  }
                  //bytes = 2 * 1024 * 1024;
                  bytes = mss * ((bytes+mss-1)/mss);
                  double simtime_ms = 196.0;
                  double start_time_ms = base_start_ms + drand() * simtime_ms;
                  flows.push_back(Flow(master, client, bytes, start_time_ms));
              }
          }
      }
  }
}

int ConnectionMatrix::genFlowBytes(){
    double x = exp_distribution(generator);
    int bytes = scale * exp(x);
    cout << "bytes " << bytes << endl;
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


void ConnectionMatrix::setFlowsFromFile(Topology* top, string filename){
  int nflows = 0; 
  int mss = Packet::data_packet_size();
  cout << " mss " << mss << endl;
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
        int from, to, bytes;
        double start_time_ms;
        ss >> from >> to >> bytes >> start_time_ms;
        bytes = mss * ((bytes+mss-1)/mss);
        if (from >= N or to >= N) continue;
        flows.push_back(Flow(from, to, bytes, start_time_ms));
        nflows++;
    }
    TMFile.close();
  }
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

