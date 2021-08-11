#include <fstream>
#include <sstream>
#include <iostream>
#include "compute_store.h"
#include "network.h"
#include "main.h"
#include "rand_regular_topology.h"
#include "clock.h"
#include "loggers.h"

const double SIMTIME = 101;
EventList eventlist;
Logfile* lg;

ComputeStore::ComputeStore() {
    // Initialize TM to all 0 entries
    TM = new int*[NSW];
	for (int i=0;i<NSW;i++){
		TM[i] = new int[NSW];
		for (int j = 0;j<NSW;j++){
			TM[i][j] = 0;
		}
	}

    // Initialize net_path to NULL
    net_path = new vector<route_t*>**[NSW];
	for (int i=0;i<NSW;i++){
		net_path[i] = new vector<route_t*>*[NSW];
		for (int j = 0;j<NSW;j++){
			net_path[i][j] = NULL;
		}
	}
}

// Copied from connection_matrix.cpp
int ComputeStore::convertHostToSwitch(int host) {	
  //cout<<"ConvertHostToSwitch: "<<host<<" : "<<NSW<<" : "<<NHOST<<" : "<< OVERSUBSCRIPTION<<" : "<<SVRPORTS<<endl;
  int nsw_less_svrport = NSW - (NHOST/OVERSUBSCRIPTION)%NSW;  // The number of switches with less servers than others = (# of hosts % # of switches)
  int myswitchindex;
  if(HETERO==1){
	  if(SVRPORTS != 1){
		 int reducedSvrport = SVRPORTS - OVERSUBSCRIPTION;
		  if(host < nsw_less_svrport * reducedSvrport)
			  myswitchindex = host / reducedSvrport;
		  else
			  myswitchindex = (host - nsw_less_svrport * reducedSvrport) / (SVRPORTS) + nsw_less_svrport;
	  }
	  else {
		  myswitchindex =  nsw_less_svrport + host;
	  }
  }
  else{
	  myswitchindex = host / SVRPORTS;
  }
  return myswitchindex;
}

void ComputeStore::getRackBasedTM(string filename) {
    int nflows = 0; 
    int mss = Packet::data_packet_size();
    cout << " mss = " << mss << endl;

    // read TM from file
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
            nflows++;

            bytes = mss * ((bytes+mss-1)/mss);
            if (from >= NHOST or to >= NHOST) continue;
            int src_sw = convertHostToSwitch(from);
            int dst_sw = convertHostToSwitch(to);
            TM[src_sw][dst_sw] += bytes;
        }
        TMFile.close();
    }
    cout << "nflows = " << nflows << endl;
}

void ComputeStore::storeRackBasedTM() {
    ofstream file;
    file.open("tm.txt");
    int src_row_id, dst_column_id;
    int* row;
    for (int count=0; count<NSW; count++) {
        src_row_id = NSW - count - 1;
        row = TM[src_row_id];
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
}

void ComputeStore::getRackBasedNetPath() {
    eventlist.setEndtime(timeFromSec(SIMTIME));
    Clock c(timeFromSec(50 / 100.), eventlist);
    stringstream filename("logfile");
    Logfile logfile(filename.str(), eventlist);
    logfile.setStartTime(timeFromSec(0));
    int logger_period_ms = 1000000;
    TcpSinkLoggerSampling sinkLogger = TcpSinkLoggerSampling(timeFromMs(logger_period_ms), eventlist);
    logfile.addLogger(sinkLogger);
    TcpLoggerSimple logTcp;
    logfile.addLogger(logTcp);
    cout << "logfile: " << filename.str() << endl;
    string rfile = "graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist";
    cout << "topology file: " << rfile << endl;
    string routing = "ecmp";
    cout << "routing: " << routing << endl;
    int korn = 0;
    cout << "korn = " << korn << endl;

    RandRegularTopology* top = new RandRegularTopology(&logfile, &eventlist, rfile, RANDOM, routing, korn);
    vector<route_t*>* available_paths_raw;
    // vector<route_t*>* available_paths_cleaned;
    // route_t* route;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            available_paths_raw = top->get_paths(i, j).second;
            if (available_paths_raw->at(0)->size() == 0) assert(i == j);
	    /*
	    available_paths_cleaned = new vector<route_t*>();
            for (int k=0; k<available_paths_raw->size(); k=k++) {
		route = new route_t();
		for (int l=0; l<available_paths_raw->at(k)->size(); l=l+2) {
			route->push_back(available_paths_raw->at(k)->at(l));
		}
                available_paths_cleaned->push_back(route);
	        assert(available_paths_raw->at(k)->size()%2 == 0);
	        assert(available_paths_raw->at(k)->size()/2 == route->size());
		delete available_paths_raw->at(k);
            }
            net_path[i][j] = available_paths_cleaned;
	    available_paths_raw->clear();
	    delete available_paths_raw;
	    */
	    net_path[i][j] = available_paths_raw;
        }
    }
}

void ComputeStore::checkRackBasedNetPath(int limit) {
    ofstream file;
    file.open("net_path.txt");
    for (int src_row=0; src_row<limit; src_row++) {
        for (int dst_column=0; dst_column<limit; dst_column++) {
            file << src_row << "\t" << dst_column << "\n";
            for (int i=0; i<net_path[src_row][dst_column]->size(); i++) {
		file << "path:\t";
		route_t *route = new route_t(*(net_path[src_row][dst_column]->at(i)));
        	for (vector<PacketSink*>::const_iterator it = route->begin(); it != route->end(); ++it) {
        	    file << (*it)->nodename() << " ";
        	}
        	file << "\n";
            }
            file << "\n";
	}
    }
    file.close();
}

void ComputeStore::deleteNetPath() {
    cout << "delete net_path" << endl;
    for (int i=0; i<NSW; i++) {
	for (int j=0; j<NSW; j++) {
	    if (net_path[i][j]) {
		for (auto p : (*net_path[i][j])) {
		    delete p;
		}
		net_path[i][j]->clear();
		delete net_path[i][j];
	    }
	}
	delete [] net_path[i];
    }	
    delete [] net_path;
}

void ComputeStore::deleteTM() {
    cout << "delete TM" << endl;
    for (int i=0; i<NSW; i++) {
	delete [] net_path[i];
    }	
    delete [] net_path;
}

