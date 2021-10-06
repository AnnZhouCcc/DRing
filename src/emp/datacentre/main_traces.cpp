#include <iostream>
#include <fstream>
#include <sstream>
#include <set>
#include <stdio.h>
#include <string.h>
#include <vector>
#include "config.h"

#define NHOST 3072 // 3072 for RRG, 2988 for DRing
#define NSW 80
#define PACKET_SIZE 1500
#define WINDOW_PARAM 3.93216

int main(int argc, char **argv) {
    int my_nhost = 1024;
    string inputFile = "traces/hpc_exact_boxlib_cns_nospec_large.csv";
    string outputTempFile = "traces/hpc_cns_rrg_temp.data";
    string outputFile = "traces/hpc_cns_rrg.data";

    ifstream ifs;
    ofstream ofs;
    string line;
    int prev_from = -1, prev_to = -1;
    uint64_t bytes = PACKET_SIZE;
    int num_flows = 0;
    line.clear();
    ifs.open(inputFile);
    ofs.open(outputTempFile);
    if (ifs.is_open()) {
        while(ifs.good()) {
            getline(ifs, line);
            stringstream ss(line);
            int number, from, to;
            ss >> number >> from >> to;
            if (prev_from == from && prev_to == to) {
                bytes += PACKET_SIZE;
            } else {
                ofs << prev_from << " " << prev_to << " " << bytes << "\n";
                num_flows++;
                prev_from = from;
                prev_to = to;
                bytes = PACKET_SIZE;
            }
        }
        ofs << prev_from << "\t" << prev_to << "\t" << bytes << "\n";
        num_flows++;
    }
    ifs.close();
    ofs.close();

    set<double> start_times_set;
    double window_end = (double)num_flows / NHOST * WINDOW_PARAM;
    cout << "window_end = " << window_end  << "->" << (int)window_end << endl;
    srand(time(0));
    while (start_times_set.size() < num_flows) {
        start_times_set.insert(rand() % (int)window_end);
    }
    vector<double> start_times_vec;
    set<double>::iterator itr;
    for (itr = start_times_set.begin(); itr != start_times_set.end(); itr++) {
        start_times_vec.push_back(*itr);
    }

    int count = 0;
    int host_multiplier = NHOST/my_nhost;
    cout << "host_multiplier = " << host_multiplier << endl;
    line.clear();
    ifs.open(outputTempFile);
    ofs.open(outputFile);
    if (ifs.is_open()) {
        while(ifs.good()) {
            getline(ifs, line);
            stringstream ss(line);
            int number, from, to;
            ss >> from >> to >> bytes;
            ofs << from*host_multiplier << " " << to*host_multiplier << " " << bytes << " " << start_times_vec.at(count) << "\n";
            count++;
        }
    }
    ifs.close();
    ofs.close();
    
    remove(outputTempFile.c_str());
}

