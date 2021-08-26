#include <fstream>
#include <sstream>
#include <iostream>
#include <queue>
#include <vector>
#include "compute_store.h"
#include "network.h"
#include "main.h"
#include "rand_regular_topology.h"
#include "clock.h"
#include "loggers.h"

#define LINKSIZE (NSW-1) * NSW + (NSW-1) + 1

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

    // Initialize net_link to 0
    net_link = new double**[NSW];
	for (int i=0;i<NSW;i++){
		net_link[i] = new double*[NSW];
		for (int j = 0;j<NSW;j++){
            net_link[i][j] = new double[LINKSIZE];
            for (int k=0; k<LINKSIZE; k++) {
                net_link[i][j][k] = 0;
            }
		}
	} 

    // Initialize net_count to 0
    net_count = new int*[NSW];
	for (int i=0;i<NSW;i++){
		net_count[i] = new int[NSW];
		for (int j = 0;j<NSW;j++){
			net_count[i][j] = 0;
		}
	}

    // Initialize net_sum to 0
    net_sum = new int*[NSW];
	for (int i=0;i<NSW;i++){
		net_sum[i] = new int[NSW];
		for (int j = 0;j<NSW;j++){
			net_sum[i][j] = 0;
		}
	}

    // Initialize D to 0
    D = new double[LINKSIZE];
    for (int i=0; i<LINKSIZE; i++) {
        D[i] = 0;
    }

    // Initialize T to 0
    T = new double**[NSW];
	for (int i=0;i<NSW;i++){
		T[i] = new double*[NSW];
		for (int j = 0;j<NSW;j++){
            T[i][j] = new double[LINKSIZE];
            for (int k=0; k<LINKSIZE; k++) {
                T[i][j][k] = 0;
            }
		}
	}

    // Initialize R_all/out/in_traffic to 0
    R_all_traffic = new int[NSW];
    for (int i=0; i<NSW; i++) {
        R_all_traffic[i] = 0;
    } 
    R_out_traffic = new int[NSW];
    for (int i=0; i<NSW; i++) {
        R_out_traffic[i] = 0;
    }
    R_in_traffic = new int[NSW];
    for (int i=0; i<NSW; i++) {
        R_in_traffic[i] = 0;
    } 

    // Initialize W to all 0
    W = new double*[NSW];
	for (int i=0;i<NSW;i++){
		W[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			W[i][j] = 0;
		}
	}

    // Initialize first_hop_index to all 0 entries
    first_hop_index = new double*[NSW];
	for (int i=0;i<NSW;i++){
		first_hop_index[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			first_hop_index[i][j] = 0;
		}
	}

    // Initialize non_first_hop_index to all 0 entries
    non_first_hop_index = new double*[NSW];
	for (int i=0;i<NSW;i++){
		non_first_hop_index[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			non_first_hop_index[i][j] = 0;
		}
	}

    // Initialize more_than_one_hop_net_count to all 0 entries
    more_than_one_hop_net_count = new int*[NSW];
	for (int i=0;i<NSW;i++){
		more_than_one_hop_net_count[i] = new int[NSW];
		for (int j = 0;j<NSW;j++){
			more_than_one_hop_net_count[i][j] = 0;
		}
	}

    // Initialize RxIndex to 0
    RxIndex = new double[NSW];
    for (int i=0; i<NSW; i++) {
        RxIndex[i] = 0;
    } 

    // Initialize S to 0
    S = new double[NSW];
    for (int i=0; i<NSW; i++) {
        S[i] = 0;
    } 

    // Initialize percentage to all 0 entries
    percentage = new double*[NSW];
	for (int i=0;i<NSW;i++){
		percentage[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			percentage[i][j] = 0;
		}
	}
}

void ComputeStore::setRoutingScheme(string routing_, int korn_) {
    routing = routing_;
    korn = korn_;
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
    file.open("fb_skewed_tm.txt");
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
    // string routing = "ecmp";
    cout << "routing: " << routing << endl;
    // int korn = 0;
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

void ComputeStore::storeRackBasedNetPath(int limit) {
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

void ComputeStore::deleteMatrices() {
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

    cout << "delete net_link" << endl;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            delete []net_link[i][j];
        }
	    delete [] net_link[i];
    }	
    delete [] net_link;

    cout << "delete net_count" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] net_count[i];
    }	
    delete [] net_count;

    cout << "delete net_sum" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] net_sum[i];
    }	
    delete [] net_sum;
}

void ComputeStore::deleteTM() {
    cout << "delete TM" << endl;
    for (int i=0; i<NSW; i++) {
	delete [] TM[i];
    }	
    delete [] TM;
}

pair<int, int> ComputeStore::extractSwitchID(string nodename) {
    // cout << "extractSwitchID: " << nodename << endl;
    int src_sw, dst_sw, src_sw_back_start_index;
    int last_index = nodename.length()-1;
    char dst_sw_second_char = nodename[last_index];
    char dst_sw_first_char = nodename[last_index-1];
    if (dst_sw_first_char == '_') {
        string dst_sw_str(1, dst_sw_second_char);
        dst_sw = stoi(dst_sw_str);
        src_sw_back_start_index = last_index-5;
    } else {
        dst_sw = stoi(nodename.substr(last_index-1, 2));
        src_sw_back_start_index = last_index-6;
    }
    char src_sw_second_char = nodename[src_sw_back_start_index];
    char src_sw_first_char = nodename[src_sw_back_start_index-1];
    if (src_sw_first_char == '_') {
        string src_sw_str(1, src_sw_second_char);
        src_sw = stoi(src_sw_str);
    } else {
        src_sw = stoi(nodename.substr(src_sw_back_start_index-1, 2));
    }
    // cout << "src_sw = " << src_sw << ", dst_sw = " << dst_sw << endl;
    return pair<int, int>(src_sw, dst_sw);
}

int ComputeStore::getLinkID(string nodename) {
    int src_sw = extractSwitchID(nodename).first;
    int dst_sw = extractSwitchID(nodename).second;
    int linkID = src_sw * NSW + dst_sw;
    // cout << "link ID = " << linkID << endl;
    return linkID;
}

void ComputeStore::getNetLinkNetSumNetCount() {
    int count, sum, linkID;
    string nodename;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            count = net_path[i][j]->size();
	    if (count == 1 && net_path[i][j]->at(0)->size() == 0) count = 0;
            sum = 0;
            for (int k=0; k<count; k++) {
                sum += (net_path[i][j]->at(k)->size())/2;
                for (int l=0; l<net_path[i][j]->at(k)->size(); l=l+2) {
                    nodename = net_path[i][j]->at(k)->at(l)->nodename();
                    linkID = getLinkID(nodename);
                    net_link[i][j][linkID] += 1.0/(double)count;
                }
            }
            net_count[i][j] = count;
	    net_sum[i][j] = sum;
        }
    }
}

void ComputeStore::storeNetLink(int limit) {
    ofstream file;
    file.open("net_link.txt");
    for (int src_row=0; src_row<limit; src_row++) {
        for (int dst_column=0; dst_column<limit; dst_column++) {
            file << src_row << "\t" << dst_column << "\n";
            for (int link_id=0; link_id<2*limit; link_id++) {
                file << net_link[src_row][dst_column][link_id] << " "; 
            }
        	file << "\n";
        }
        file << "\n";
    }
    file.close();
}

void ComputeStore::storeNetSumNetCount(int limit) {
    ofstream file;
    file.open("net_sum_net_count.txt");
    for (int src_row=0; src_row<limit; src_row++) {
        for (int dst_column=0; dst_column<limit; dst_column++) {
            file << src_row << "\t" << dst_column << "\t" << net_sum[src_row][dst_column] << "\t" << net_count[src_row][dst_column] << "\n";
        }
        file << "\n";
    }
    file.close();
}

void ComputeStore::computeD() {
    cout << "compute D: LINKSIZE = " << LINKSIZE << endl;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            for (int k=0; k<LINKSIZE; k++) {
                if (net_link[i][j][k] > 0) {
                    D[k] += (net_link[i][j][k] * (double)TM[i][j]);
                }
            }
        }
    }
}

void ComputeStore::computeT() {
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            for (int k=0; k<LINKSIZE; k++) {
                T[i][j][k] = (net_link[i][j][k] / D[k] * (double)TM[i][j]);
		if (T[i][j][k] < 0.0) {
		    cout << "**Overflow!**" << endl;
		    cout << net_link[i][j][k] << " " << (double)TM[i]    [j] / D[k] << endl;
		    cout << i << " " << j << " " << k << endl; 
		}
            }
        }
    }
}

double ComputeStore::computePlen() {
    int64_t sum = 0, count = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (TM[i][j] > 0) {
                sum += net_sum[i][j];
                count += net_count[i][j];
            }
        }
    }
    return (double)sum/(double)count;
}

int ComputeStore::computeNe(double e) {
    double* links = new double[LINKSIZE];
    for (int k=0; k<LINKSIZE; k++) {
        links[k] = 0;
    }
    int old_prob, new_prob;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (TM[i][j] > 0) {
                for (int k=0; k<LINKSIZE; k++) {
                    old_prob = links[k];
                    new_prob = net_link[i][j][k];
		    assert(old_prob >= 0.0);
		    assert(new_prob >= 0.0);
                    if (new_prob > old_prob) {
                        links[k] = new_prob;
                    }
                }
            }
        }
    }
    int count = 0;
    for (int k=0; k<LINKSIZE; k++) {
        if (links[k] > e) {
            count++;
        }
    }
    delete links;
    return count;
}

void ComputeStore::deleteComputations() {
    cout << "delete D" << endl;
    delete [] D;

    cout << "delete T" << endl;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            delete [] T[i][j];
        }
	    delete [] T[i];
    }	
    delete [] T;

    cout << "delete R_all/out/in_traffic" << endl;
    delete [] R_all_traffic;
    delete [] R_out_traffic;
    delete [] R_in_traffic;

    cout << "delete W" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] W[i];
    }	
    delete [] W;
}

void ComputeStore::storeD() {
    ofstream file;
    string filename = "D_rrg_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    for (int i=0; i<LINKSIZE; i++) {
        file << D[i] << "\t";
    }
    file.close();
}

void ComputeStore::checkValidity() {
    cout << "Check validity NetPath" << endl;
    route_t * route;
    int num_items;
    int src_id, dst_id;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            for (int k=0; k<net_path[i][j]->size(); k++) {
                route = net_path[i][j]->at(k);
                num_items = route->size();
                if (num_items > 0) {
                src_id = extractSwitchID(route->at(0)->nodename()).first;
                dst_id = extractSwitchID(route->at(num_items-2)->nodename()).second;
                if (src_id != i) {
                    cout << "**Error found**" << endl;
                    cout << "src_id != i in net_path" << endl;
                    cout << "src_id = " << src_id << ", i = " << i << endl; 
                    cout << "j = " << j << ", k = " << k << endl;
                    cout << "**End**" << endl;
                }
                if (dst_id != j) {
                    cout << "**Error found**" << endl;
                    cout << "dst_id != j in net_path" << endl;
                    cout << "dst_id = " << dst_id << ", j = " << j << endl; 
                    cout << "i = " << i << ", k = " << k << endl;
                    cout << "**End**" << endl;
                }
                }
            }
        }
    }

    cout << "Check validity NetLink" << endl;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            for (int k=0; k<LINKSIZE; k++) {
                if (net_link[i][j][k] < 0) {
                    cout << "**Error found**" << endl;
                    cout << "net_link[i][j][k] < 0" << endl;
                    cout << "net_link[i][j][k] = " << net_link[i][j][k] << ", i = " << i << ", j = " << j << ", k = " << k << endl; 
                    cout << "**End**" << endl; 
                }
            }
        }
    }

    cout << "Check validity NetSum" << endl;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
                if (net_sum[i][j] < 0) {
                    cout << "**Error found**" << endl;
                    cout << "net_sum[i][j] < 0" << endl;
                    cout << "net_sum[i][j] = " << net_sum[i][j] << ", i = " << i << ", j = " << j << endl; 
                    cout << "**End**" << endl; 
                }
                if (net_sum[i][j] == 0 && net_path[i][j]->at(0)->size() != 0) {
                    cout << "**Error found**" << endl;
                    cout << "net_sum[i][j] == 0 && net_path[i][j]->at(0)->size() != 0" << endl;
                    cout << "net_sum[i][j] = " << net_sum[i][j] << ", i = " << i << ", j = " << j << ", net_path[i][j]->at(0)->size() = " << net_path[i][j]->at(0)->size() << endl; 
                    cout << "**End**" << endl; 
                }
        }
    }

    cout << "Check validity NetCount" << endl;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
                if (net_count[i][j] < 0) {
                    cout << "**Error found**" << endl;
                    cout << "net_count[i][j] < 0" << endl;
                    cout << "net_count[i][j] = " << net_count[i][j] << ", i = " << i << ", j = " << j << endl; 
                    cout << "**End**" << endl; 
                }
                if (net_count[i][j] == 0 && net_path[i][j]->at(0)->size() != 0) {
                    cout << "**Error found**" << endl;
                    cout << "net_count[i][j] == 0 && net_path[i][j]->at(0)->size() != 0" << endl;
                    cout << "net_count[i][j] = " << net_count[i][j] << ", i = " << i << ", j = " << j << ", net_path[i][j]->at(0)->size() = " << net_path[i][j]->at(0)->size() << endl; 
                    cout << "**End**" << endl; 
                }
        }
    }

    cout << "Check validity D" << endl;
    for (int k=0; k<LINKSIZE; k++) {
	    if (D[k] < 0) {
            cout << "**Error found**" << endl;
            cout << "D[k] < 0" << endl;
            cout << "k = " << k << ", D[k] = " << D[k] << endl;
            cout << "**End**" << endl;
        }       
    }

    cout << "Check validity T" << endl;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            for (int k=0; k<LINKSIZE; k++) {
                if (T[i][j][k] < 0) {
                    cout << "**Error found**" << endl;
                    cout << "T[i][j][k] < 0" << endl;
                    cout << "T[i][j][k] = " << T[i][j][k] << "i = " << i << ", j = " << j << ", k = " << k << endl;
                    cout << "**End**" << endl;
                }
            }
        }
    }
}

void ComputeStore::computeR() {
    // Compute R_all_traffic
    int sum, k;
    for (int a=0; a<NSW; a++) {
        sum = 0;
        for (int b=0; b<NSW; b++) {
            k = a*NSW+b;
            sum += D[k]; // D[k] here can be 0
            k = b*NSW+a;
            sum += D[k]; // D[k] here can be 0
        }
        R_all_traffic[a] = sum;
    }

    // Compute R_in_traffic
    int in_sum;
    for (int j=0; j<NSW; j++) {
        in_sum = 0;
        for (int i=0; i<NSW; i++) {
            if (i!=j) in_sum += TM[i][j];
        }
        R_in_traffic[j] = in_sum;
    }

    // Compute R_out_traffic
    int out_sum;
    for (int i=0; i<NSW; i++) {
        out_sum = 0;
        for (int j=0; j<NSW; j++) {
            if (i!=j) out_sum += TM[i][j];
        }
        R_out_traffic[i] = out_sum;
    }
}

void ComputeStore::storeR() {
    ofstream file;
    string filename = "R_rrg_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "switch\tall\tin\tout\ttransit(w in)\ttransit(no in; half)\n";
    int transit, combined;
    for (int a=0; a<NSW; a++) {
        file << a << "\t" << R_all_traffic[a] << "\t";
        file << R_in_traffic[a] << "\t" << R_out_traffic[a] << "\t";
        file << R_all_traffic[a]-R_out_traffic[a] << "\t";
        file << (R_all_traffic[a]-R_out_traffic[a]-R_in_traffic[a])/2 << "\n";
    }
    file.close();    
}

bool D_comparator(pair<int,double>D1, pair<int,double>D2) {
    return D1.second > D2.second;
}

void ComputeStore::storeW(int limit) {
    priority_queue<pair<int,double>, vector< pair<int,double> >, function< bool(pair<int,double>, pair<int,double>)> > pq(D_comparator);
    for (int k=0; k<LINKSIZE; k++) {
        if (D[k] > 0) {
            pair<int,double> pr (k, D[k]);
            pq.push(pr);
        }
    }

    vector< pair<int,double> > max {};
    pair<int,double> max_pr;
    for (int a=0; a<limit; a++) {
        max_pr = pq.top();
        max.push_back(max_pr);
        pq.pop();
    }

    int linkID;
    double demand;
    for (int a=0; a<limit; a++) {
        linkID = max.at(a).first;
        demand = max.at(a).second;
        int src = linkID/NSW;
        int dst = linkID%NSW;

        // Set W back to all 0
        for (int i=0;i<NSW;i++){
            for (int j = 0;j<NSW;j++){
                W[i][j] = 0;
            }
        }

        for (int i=0; i<NSW; i++) {
            for (int j=0; j<NSW; j++) {
                int count = net_count[i][j];
                for (int k=0; k<count; k++) {
                    for (int l=0; l<net_path[i][j]->at(k)->size(); l++) {
                        string hop_name = net_path[i][j]->at(k)->at(l)->nodename();
                        int hop_src = extractSwitchID(hop_name).first;
                        int hop_dst = extractSwitchID(hop_name).second;

                        if (src == hop_src && dst == hop_dst) {
                            W[i][j] += (1.0/count) * TM[i][j];
                        }
                    }
                }
            }
        }

        // Print out W
        ofstream file;
        string filename = "W_" + to_string(a) + "_rrg_" + routing + to_string(korn) + ".txt";
        file.open(filename);
        file << "Link source switch: " << src << ", destination switch: " << dst << ", total demand on the link = " << demand;
        int src_row_id, dst_column_id;
        double* row;
        for (int count=0; count<NSW; count++) {
            src_row_id = NSW - count - 1;
            row = W[src_row_id];
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
}

void ComputeStore::computeIndex() {
    // for (int i=0; i<NSW; i++) {
    //     for (int j=0; j<NSW; j++) {
    //         vector<route_t *> *available_paths = net_path[i][j];
    //         map<int, int> id_weight_map;
    //         for (int i=0; i<available_paths->size(); i++) {
    //             route_t *path = available_paths->at(i);
    //             for (int j=0; j<path->size(); j=j+2) {
    //                 string nodename = path->at(j)->nodename();
    //                 int link_id = getLinkID(nodename);
    //                 if (id_weight_map.find(link_id) == id_weight_map.end()) {
    //                     // Not found, create new entry
    //                     id_weight_map[link_id] = 1;
    //                 } else {
    //                     id_weight_map[link_id] += 1;
    //                 }
    //             }
    //         }
    //         int sum = 0;
    //         for (auto entry : id_weight_map) {
    //             int weight = entry.second;
    //             sum += (weight * weight);
    //         }
    //         int count = net_count[i][j];
    //         if (count == 0) {
    //             index[i][j] = 0;
    //         } else {
    //             index[i][j] = ((double)sum / (count * count));
    //         }
    //     }
    // }

    // for (int i=0; i<NSW; i++) {
    //     for (int j=0; j<NSW; j++) {
    //         vector<route_t *> *available_paths = net_path[i][j];
    //         map<int, int> first_hop_id_weight_map;
    //         map<int, int> non_first_hop_id_weight_map;
    //         int more_than_one_hop_count = 0;
    //         for (int i=0; i<available_paths->size(); i++) {
    //             if (available_paths->at(i)->size() > 0) {
    //                 // Only consider the first hop
    //                 string nodename = available_paths->at(i)->at(0)->nodename();
    //                 int link_id = getLinkID(nodename);
    //                 if (first_hop_id_weight_map.find(link_id) == first_hop_id_weight_map.end()) {
    //                     // Not found, create new entry
    //                     first_hop_id_weight_map[link_id] = 1;
    //                 } else {
    //                     first_hop_id_weight_map[link_id] += 1;
    //                 }
    //             }
    //             if (available_paths->at(i)->size() > 2) {
    //                 more_than_one_hop_count++;
    //             }
    //             for (int j=2; j<available_paths->at(i)->size(); j=j+2) {
    //                 string nodename = available_paths->at(i)->at(j)->nodename();
    //                 int link_id = getLinkID(nodename);
    //                 if (non_first_hop_id_weight_map.find(link_id) == non_first_hop_id_weight_map.end()) {
    //                     // Not found, create new entry
    //                     non_first_hop_id_weight_map[link_id] = 1;
    //                 } else {
    //                     non_first_hop_id_weight_map[link_id] += 1;
    //                 }
    //             }
    //         }
    //         more_than_one_hop_net_count[i][j] = more_than_one_hop_count;

    //         int sum = 0;
    //         for (auto entry : first_hop_id_weight_map) {
    //             int weight = entry.second;
    //             sum += (weight * weight);
    //         }
    //         int count = net_count[i][j];
    //         if (count == 0) {
    //             first_hop_index[i][j] = 0;
    //         } else {
    //             first_hop_index[i][j] = ((double)sum / (count * count));
    //         }

    //         int non_first_hop_sum = 0;
    //         for (auto entry : non_first_hop_id_weight_map) {
    //             int weight = entry.second;
    //             non_first_hop_sum += (weight * weight);
    //         }
    //         if (more_than_one_hop_count == 0) {
    //             non_first_hop_index[i][j] = 0;
    //         } else {
    //             non_first_hop_index[i][j] = ((double)non_first_hop_sum / (more_than_one_hop_count * more_than_one_hop_count));
    //         }
    //     }
    // }

    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            vector<route_t *> *available_paths = net_path[i][j];
            map<int, int> first_hop_id_weight_map;
            int more_than_one_hop_count = 0;
            for (int i=0; i<available_paths->size(); i++) {
                if (available_paths->at(i)->size() > 0) {
                    // Only consider the first hop
                    string nodename = available_paths->at(i)->at(0)->nodename();
                    int link_id = getLinkID(nodename);
                    if (first_hop_id_weight_map.find(link_id) == first_hop_id_weight_map.end()) {
                        // Not found, create new entry
                        first_hop_id_weight_map[link_id] = 1;
                    } else {
                        first_hop_id_weight_map[link_id] += 1;
                    }
                }
                if (available_paths->at(i)->size() > 2) {
                    more_than_one_hop_count++;
                }
            }
            more_than_one_hop_net_count[i][j] = more_than_one_hop_count;

            int sum = 0;
            for (auto entry : first_hop_id_weight_map) {
                int weight = entry.second;
                sum += (weight * weight);
            }
            int count = net_count[i][j];
            if (count == 0) {
                first_hop_index[i][j] = 0;
            } else {
                first_hop_index[i][j] = ((double)sum / (count * count));
            }

            if (more_than_one_hop_count > 0) {
                PathGraph *graph = new PathGraph(i, j, this);
                non_first_hop_index[i][j] = graph->computeIndex();
                delete graph;
            } else {
                non_first_hop_index[i][j] = 0;
            }
        }
    }
}

void ComputeStore::deletePathIndex() {
    cout << "delete first_hop_index" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] first_hop_index[i];
    }	
    delete [] first_hop_index;

    cout << "delete non_first_hop_index" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] non_first_hop_index[i];
    }	
    delete [] non_first_hop_index;

    cout << "delete RxIndex" << endl;
    delete [] RxIndex;

    cout << "delete more_than_one_hop_net_count" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] more_than_one_hop_net_count[i];
    }	
    delete [] more_than_one_hop_net_count;  

    cout << "delete S" << endl;
    delete [] S;  

    cout << "delete percentage" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] percentage[i];
    }	
    delete [] percentage;
}

void ComputeStore::computeRxIndex() {
    // for (int a=0; a<NSW; a++) {
    //     int transit_traffic = R_all_traffic[a] - R_in_traffic[a] - R_out_traffic[a]; // This is twice the transit traffic.
    //     double demand = 0;
    //     double sum_path_index = 0;
    //     for (int i=0; i<NSW; i++) {
    //         for (int j=0; j<NSW; j++) {
    //             if (i != j && i!=a && j!=a) {
    //                 sum_path_index += index[i][j];
    //             }
    //         }
    //     }
    //     int count_path_index = (NSW-1) * (NSW-1);
    //     double average_path_index = sum_path_index/count_path_index;
    //     demand += transit_traffic * average_path_index;

    //     double sum_out_index = 0;
    //     for (int j=0; j<NSW; j++) {
    //         if (a!=j) {
    //             sum_out_index += index[a][j];
    //         }
    //     }
    //     double average_out_index = sum_out_index/(NSW-1);
    //     demand += R_out_traffic[a] * average_out_index;

    //     double sum_in_index = 0;
    //     for (int i=0; i<NSW; i++) {
    //         if (a!=i) {
    //             sum_in_index += index[i][a];
    //         }
    //     }
    //     double average_in_index = sum_in_index/(NSW-1);
    //     demand += R_in_traffic[a] * average_in_index;

    //     RxIndex[a] = demand;
    // }
}

void ComputeStore::storeRxIndex() {
    ofstream file;
    string filename = "RxIndex_rrg_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "switch\tRxIndex\n";
    for (int a=0; a<NSW; a++) {
        file << a << "\t" << RxIndex[a] << "\n";
    }
    file.close();    
}

void ComputeStore::computeNStoreRxIndexWithStats() {
//     double* average_path_index_arr = new double[NSW];
//     double* average_out_index_arr = new double[NSW];
//     double* average_in_index_arr = new double[NSW];
// 	for (int i=0;i<NSW;i++){
//         average_path_index_arr[i] = 0;
//         average_out_index_arr[i] = 0;
//         average_in_index_arr[i] = 0;
// 	}

//     for (int a=0; a<NSW; a++) {
//         int transit_traffic = R_all_traffic[a] - R_in_traffic[a] - R_out_traffic[a]; // This is twice the transit traffic.
//         double demand = 0;
//         double sum_path_index = 0;
//         for (int i=0; i<NSW; i++) {
//             for (int j=0; j<NSW; j++) {
//                 if (i != j && i!=a && j!=a) {
//                     sum_path_index += index[i][j];
//                 }
//             }
//         }
//         int count_path_index = (NSW-1) * (NSW-1);
//         double average_path_index = sum_path_index/count_path_index;
//         demand += transit_traffic * average_path_index;
//         average_path_index_arr[a] = average_path_index;

//         double sum_out_index = 0;
//         for (int j=0; j<NSW; j++) {
//             if (a!=j) {
//                 sum_out_index += index[a][j];
//             }
//         }
//         double average_out_index = sum_out_index/(NSW-1);
//         demand += R_out_traffic[a] * average_out_index;
//         average_out_index_arr[a] = average_out_index;

//         double sum_in_index = 0;
//         for (int i=0; i<NSW; i++) {
//             if (a!=i) {
//                 sum_in_index += index[i][a];
//             }
//         }
//         double average_in_index = sum_in_index/(NSW-1);
//         demand += R_in_traffic[a] * average_in_index;
//         average_in_index_arr[a] = average_in_index;

//         RxIndex[a] = demand;
//     }

//     ofstream file;
//     string filename = "RxIndexWithStats_rrg_" + routing + to_string(korn) + ".txt";
//     file.open(filename);
//     file << "switch\tRxIndex\ttransit\tindex\tout\tindex\tin\tindex\n";
//     for (int a=0; a<NSW; a++) {
//         file << a << "\t" << RxIndex[a] << "\t";
//         file << (R_all_traffic[a]-R_out_traffic[a]-R_in_traffic[a]) << "\t" << average_path_index_arr[a] << "\t";
//         file << R_out_traffic[a] << "\t" << average_out_index_arr[a] << "\t";
//         file << R_in_traffic[a] << "\t" << average_in_index_arr[a] << "\n";
//     }
//     file.close(); 

//     delete average_path_index_arr;
//     delete average_out_index_arr;
//     delete average_in_index_arr;

    double* average_out_index_arr = new double[NSW];
    double* average_transit_index_arr = new double[NSW];
	for (int i=0;i<NSW;i++){
        average_out_index_arr[i] = 0;
        average_transit_index_arr[i] = 0;
	}

    for (int a=0; a<NSW; a++) {
        double demand = 0;
        int transit_traffic = (R_all_traffic[a] - R_out_traffic[a]);
        double sum_transit_index = 0;
        int count_transit_index = 0;
        for (int i=0; i<NSW; i++) {
            for (int j=0; j<NSW; j++) {
                if (i != j && i!=a && j!=a) {
                    sum_transit_index += non_first_hop_index[i][j];
                    if (non_first_hop_index[i][j] > 0) {
                        count_transit_index++;
                    }
                }
            }
        }
        double average_transit_index = sum_transit_index/count_transit_index;
        demand += transit_traffic * average_transit_index;
        average_transit_index_arr[a] = average_transit_index;

        double sum_out_index = 0;
        for (int j=0; j<NSW; j++) {
            if (a!=j) {
                sum_out_index += first_hop_index[a][j];
            }
        }
        double average_out_index = sum_out_index/(NSW-1);
        demand += R_out_traffic[a] * average_out_index;
        average_out_index_arr[a] = average_out_index;

        RxIndex[a] = demand;
    }

    ofstream file;
    string filename = "RxIndexWithStats_rrg_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "switch\tRxIndex\ttransit_traffic\ttransit_index\tout_traffic\tout_index\n";
    for (int a=0; a<NSW; a++) {
        file << a << "\t" << RxIndex[a] << "\t";
        file << (R_all_traffic[a]-R_out_traffic[a]) << "\t" << average_transit_index_arr[a] << "\t";
        file << R_out_traffic[a] << "\t" << average_out_index_arr[a] << "\n";
    }
    file.close(); 

    delete average_out_index_arr;
    delete average_transit_index_arr;
}

void ComputeStore::storeIndex() {
    ofstream file;
    string filename = "index_rrg_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            file << first_hop_index[i][j] << "\n";
        }
    }
    file.close();    
}

void ComputeStore::computeNStoreSWithStats() {
    cout << "**computeNStoreSWithStats**" << endl;
    // Compute total TM.
    total_TM = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            total_TM += TM[i][j];
        }
    }
    cout << "total_TM = " << total_TM << endl;

    // Compute average path length.
    int64_t sum = 0, count = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            sum += net_sum[i][j];
            count += net_count[i][j];
        }
    }
    average_path_length = (double)sum/(double)count;
    cout << "average_path_length = " << average_path_length << endl;

    // Compute the percentage of traffic that requires transit i.e. has length >1.
    double total_percentage = 0;
    int percentage_count = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            vector<route_t *> *available_paths = net_path[i][j];
            int more_than_one_hop_count = 0;
            for (int i=0; i<available_paths->size(); i++) {
                route_t *path = available_paths->at(i); 
                if (path->size() > 2) more_than_one_hop_count++;
            }      
            if (net_count[i][j] > 0) {
                percentage_count++;
                percentage[i][j] = (double)more_than_one_hop_count / net_count[i][j];
                total_percentage += percentage[i][j];
            } else {
                percentage[i][j] = 0;
            }   
        }
    }
    percentage_traffic_requiring_transit = total_percentage / percentage_count;
    cout << "percentage_traffic_requiring_transit = " << percentage_traffic_requiring_transit << endl;

    // Compute S
    double* average_non_first_hop_index = new double[NSW];
    double* average_first_hop_index = new double[NSW];
    int* out_traffic_per_rack = new int[NSW];
	for (int i=0;i<NSW;i++){
        average_non_first_hop_index[i] = 0;
        average_first_hop_index[i] = 0;
        out_traffic_per_rack[i] = 0;
	}
    
    for (int a=0; a<NSW; a++) {
        double non_first_hop_sum = 0;
        int non_first_hop_count = 0;
        for (int i=0; i<NSW; i++) {
            for (int j=0; j<NSW; j++) {
                if (i != j && i!=a && j!=a) {
                    non_first_hop_sum+= non_first_hop_index[i][j];
                    if (non_first_hop_index[i][j] > 0) non_first_hop_count++;
                }
            }
        }
        average_non_first_hop_index[a] = non_first_hop_sum / non_first_hop_count;

        double first_hop_sum = 0;
        int out_traffic = 0;
        for (int j=0; j<NSW; j++) {
            if (a!=j) {
                first_hop_sum += first_hop_index[a][j];
                out_traffic += TM[a][j];
            }
        }
        average_first_hop_index[a] = first_hop_sum / (NSW-1);
        out_traffic_per_rack[a] = out_traffic;
    }

    for (int a=0; a<NSW; a++) {
        double overall_congestion = total_TM*average_path_length*percentage_traffic_requiring_transit*average_non_first_hop_index[a]/NSW;
        double own_traffic = out_traffic_per_rack[a] * average_first_hop_index[a];
        S[a] = overall_congestion + own_traffic;
    }

    // Write S
    ofstream file;
    string filename = "SWithStats_rrg_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "switch\tS\taverage_non_first_hop_index\tout_traffic_per_rack\taverage_first_hop_index\n";
    for (int a=0; a<NSW; a++) {
        file << a << "\t" << S[a] << "\t";
        file << average_non_first_hop_index[a] << "\t";
        file << out_traffic_per_rack[a] << "\t" << average_first_hop_index[a] << "\n";
    }
    file.close(); 

    delete average_non_first_hop_index;
    delete average_first_hop_index;
    delete out_traffic_per_rack;
}

PathNode::PathNode() {
    load = 0;
}

PathEdge::PathEdge() {
    load = 0;
    weight = 0;
    visited = false;
}

PathGraph::PathGraph(int src, int dst, ComputeStore *computestore) {
    // cout << "Initializing PathGraph" << endl;
    store = computestore;
    available_paths = store->net_path[src][dst];
    graph_src_id = src;
    graph_dst_id = dst;

    // Construct graph
    // cout << "Constructing graph" << endl;
    for (int i=0; i<available_paths->size(); i++) {
        // cout << "Working on path " << i << "..." << endl;
        route_t *path = available_paths->at(i);
        for (int j=0; j<path->size(); j=j+2) {
            string nodename = path->at(j)->nodename();
            // cout << "Working with node " << nodename;
            int link_id = store->getLinkID(nodename);
            int src_id = store->extractSwitchID(nodename).first;
            int dst_id = store->extractSwitchID(nodename).second;
            // cout << "with link_id=" << link_id << ", src_id=" << src_id << ", dst_id=" << dst_id << endl;
            PathEdge *edge;
            PathNode *src_node;
            PathNode *dst_node;
            if (id_edge_map.find(link_id) == id_edge_map.end()) {
                edge = new PathEdge();
                edge->id = link_id;
                edge->weight = 1;
                id_edge_map[link_id] = edge;
                route_edge_map[nodename] = edge;
                if (id_node_map.find(src_id) == id_node_map.end()) {
                    src_node = new PathNode();
                    src_node->id = src_id;
                    src_node->outgoing_edges.push_back(edge);
                    id_node_map[src_id] = src_node;
                } else {
                    src_node = id_node_map[src_id];
                    src_node->outgoing_edges.push_back(edge);
                }
                if (id_node_map.find(dst_id) == id_node_map.end()) {
                    dst_node = new PathNode();
                    dst_node->id = dst_id;
                    dst_node->incoming_edges.push_back(edge);
                    id_node_map[dst_id] = dst_node;
                } else {
                    dst_node = id_node_map[dst_id];
                    dst_node->incoming_edges.push_back(edge);
                }
                edge->from = src_node;
                edge->to = dst_node;
            } else {
                edge = id_edge_map[link_id];
                edge->weight += 1;
            }
        }
    }
}

double PathGraph::computeIndex() {
    // cout << "PathGraph computeIndex" << endl;
    double sum = 0;
    int length = 0;
    for (int i=0; i<available_paths->size(); i++) {
        route_t *path = available_paths->at(i);
        if (path->size() > 2) {
            length += (path->size()-2)/2;
            for (int j=2; j<path->size(); j=j+2) {
                string nodename = path->at(j)->nodename();
                PathEdge *edge = route_edge_map[nodename]; 
                sum += (edge->weight)*(edge->weight);
            }
        }
    }
    // cout << "Have looked through all paths" << endl;
    int more_than_one_hop = store->more_than_one_hop_net_count[graph_src_id][graph_dst_id];
    // cout << "Cannot access store?" << endl;
    // cout << "more_than_one_hop = " << more_than_one_hop << endl;
    if (more_than_one_hop > 0) {
        int all_hops = store->net_count[graph_src_id][graph_dst_id];
        double ind = (sum / (more_than_one_hop * all_hops));
        double average_length = length / (double)more_than_one_hop;
        // cout << "average_length = " << average_length << endl;
        ind = ind / average_length;
        index = ind;
        return ind;
    } else {
        index = 0;
        return 0;
    }
    // cout << "PathGraph computeIndex end" << endl;
}

// void PathGraph::computeIndex(int source_load) {
//     PathNode *graph_src_node = id_node_map[graph_src_id];
//     graph_src_node->load = source_load;
//     int total_edge_weights = 0;
//     for (int i=0; i<graph_src_node->outgoing_edges.size(); i++) {
//         PathEdge *edge = (PathEdge *)graph_src_node->outgoing_edges.at(i);
//         total_edge_weights += edge->weight;
//     }
//     double one = source_load / (double)total_edge_weights;

//     PathEdge *edge;
//     for (auto entry : id_edge_map) {
//         edge = entry.second;
//         edge->load = edge->weight * one;
//     }

//     double sum = 0;
//     int count = available_paths->size();
//     for (int i=0; i<count; i++) {
//         route_t *path = available_paths->at(i);
//         for (int j=0; j<path->size(); j=j+2) {
//             sum += route_edge_map[path->at(j)->nodename()]->load;
//         }
//     }
//     index = sum / count;
// }

// void PathGraph::computeIndex(int source_load) {
//     PathNode *graph_src_node = id_node_map[graph_src_id];
//     graph_src_node->load = source_load;
//     queue<PathNode *> to_visit;
//     // Update for the graph source node separately
//     int total_edge_weights = 0;
//     for (int i=0; i<graph_src_node->outgoing_edges.size(); i++) {
//         PathEdge *edge = (PathEdge *)graph_src_node->outgoing_edges.at(i);
//         total_edge_weights += edge->weight;
//     }
//     for (int i=0; i<graph_src_node->outgoing_edges.size(); i++) {
//         PathEdge *edge = (PathEdge *)graph_src_node->outgoing_edges.at(i);
//         edge->load = source_load * (edge->weight / (double)total_edge_weights);
//         edge->visited = true;
//         to_visit.push(edge->to);
//     }
//     // Update all other nodes with a process similar to BFS
//     while (!to_visit.empty()) {
//         PathNode *node = to_visit.front();
//         // Calculate load for node
//         for (int i=0; i<node->incoming_edges.size(); i++) {
//             PathEdge *edge = (PathEdge *)node->incoming_edges.at(i);
//             if (edge->visited) {
//                 node->load += edge->load;
//             } else {
//                 node->load = 0;
//                 break;
//             }
//         }
//         // Calculate load for the outgoing edges
//         if (node->load > 0) {
//             total_edge_weights = 0;
//             for (int i=0; i<node->outgoing_edges.size(); i++) {
//                 PathEdge *edge = (PathEdge *)node->outgoing_edges.at(i);
//                 total_edge_weights += edge->weight;
//             }
//             for (int i=0; i<node->outgoing_edges.size(); i++) {
//                 PathEdge *edge = (PathEdge *)node->outgoing_edges.at(i);
//                 edge->load = node->load * (edge->weight / (double)total_edge_weights);
//                 edge->visited = true;
//                 to_visit.push(edge->to);
//             }
//         }
//         to_visit.pop();
//     }
// }

void PathGraph::printNetPath() {
    cout << "**Printing NetPath**" << endl;
    for (int i=0; i<available_paths->size(); i++) {
        cout << i << ": ";
        route_t *path = available_paths->at(i);
        for (int j=0; j<path->size(); j=j+2) {
            cout << path->at(j)->nodename() << " ";
        }
        cout << endl;
    }

}

void PathGraph::printGraph() {
    cout << "**Printing graph**" << endl;
    cout << "graph_src_id = " << graph_src_id << ", graph_dst_id = " << graph_dst_id << endl;
    cout << "Nodes: " << endl;
    int node_id;
    PathNode *node;
    for (auto entry : id_node_map) {
        node_id = entry.first;
        node = entry.second;
        cout << "id=" << node_id << ": " << endl;
        cout << "\tincoming edges: " << endl;
        for (int i=0; i<node->incoming_edges.size(); i++) {
            cout << "\t\tid=" << node->incoming_edges.at(i)->id << ", load=" << node->incoming_edges.at(i)->load << endl;
        }
        cout << endl;
        cout << "\toutgoing edges: " << endl;
        for (int i=0; i<node->outgoing_edges.size(); i++) {
            cout << "\t\tid=" << node->outgoing_edges.at(i)->id << ", load=" << node->outgoing_edges.at(i)->load << endl;
        }
        cout << endl;
    }

    cout << "Edges: " << endl;
    int edge_id;
    PathEdge *edge;
    for (auto entry : id_edge_map) {
        edge_id = entry.first;
        edge = entry.second;
        cout << "\tid=" << edge_id << ": ";
        cout << "from node " << edge->from->id << " to node " << edge->to->id;
        cout << ", weight=" << edge->weight;
        cout << ", load=" << edge->load;
        cout << ", visited=" << edge->visited << endl;
    }

    // cout << "route_edge_map: " << endl;
    // string route_name;
    // PathEdge *_edge;
    // for (auto entry : route_edge_map) {
    //     route_name= entry.first;
    //     _edge = entry.second;
    //     cout << "route name is " << route_name << ", ";
    //     cout << "edge from node " << edge->from->id << " to node " << edge->to->id;
    //     cout << ", id=" << edge->id << endl;
    // }    
}
