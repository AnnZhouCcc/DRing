#include <fstream>
#include <sstream>
#include <iostream>
#include "compute_store.h"
#include "network.h"
#include "main.h"

ComputeStore::ComputeStore() {
    // Initialize TM to all 0 entries
    TM = new int*[NSW];
	for (int i=0;i<NSW;i++){
		TM[i] = new int[NSW];
		for (int j = 0;j<NSW;j++){
			TM[i][j] = 0;
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
    file.open("tm.data");
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