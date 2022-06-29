#include "../config.h"
#include <sstream>
#include <iostream>
#include <fstream>
#include <string.h>

int getRackFromServer(int numservers, int numracks, int whichserver) {
    int quotient = numservers/numracks;
    int remainder = numservers%numracks;
    int whichrack;
    if (whichserver < (numracks-remainder)*quotient) {
        whichrack = whichserver/quotient;
    } else {
        whichserver -= (numracks-remainder)*quotient;
        whichrack = ( whichserver/(quotient+1)) + (numracks-remainder);
    }
    if (whichrack >= numracks) cout << "Warning: whichrack" << endl;
    return whichrack;
}

int main(int argc, char **argv) {
    int numservers = 3072;
    int numracks = 80;
    string filename = "synthetictrafficfiles/cluster_b/generated_flows_27000_30000";
    string tmfilename = "synthetictrafficfiles/cluster_b/check_flows_27000_30000";

    uint64_t** traffic_per_rack_pair = new uint64_t*[numracks];
    for (int i=0; i<numracks; i++) {
        traffic_per_rack_pair[i] = new uint64_t[numracks];
        for (int j=0; j<numracks; j++) {
            traffic_per_rack_pair[i][j] = 0;
        }
    }
  
    ifstream TMFile(filename.c_str());
    string line;
    line.clear();
    if (TMFile.is_open()){
      while(TMFile.good()){
        getline(TMFile, line);
        //Whitespace line
        if (line.find_first_not_of(' ') == string::npos) break;
        stringstream ss(line);
        int fromserver, toserver, fromrack, torack;
        uint64_t bytes;
        double start_time_ms;
        ss >> fromserver >> toserver >> bytes >> start_time_ms;
        fromrack = getRackFromServer(numservers,numracks,fromserver);
        torack = getRackFromServer(numservers,numracks,toserver);
        traffic_per_rack_pair[fromrack][torack] += bytes;
      }
      TMFile.close();
    }

    ofstream file;
    file.open(tmfilename);
    int src_row_id, dst_column_id;
    uint64_t* row;
    for (int count=0; count<numracks; count++) {
        src_row_id = numracks - count - 1;
        row = traffic_per_rack_pair[src_row_id];
        file << src_row_id << "\t";
        for (int dst_column_id=0; dst_column_id<numracks; dst_column_id++) {
            file << row[dst_column_id] << "\t";
        }
        file << "\n";
    }
    file << "\t";
    for (int i=0; i<numracks; i++) {
        file << i << "\t";
    }
    file.close();

    for (int i=0; i<numracks; i++) {
	    delete [] traffic_per_rack_pair[i];
    }
    delete [] traffic_per_rack_pair;
}

