#include <fstream>
#include <sstream>
#include <iostream>
#include <queue>
#include <vector>
#include <functional>
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

string ntoa(double n) {
    stringstream s;
    s << n;
    return s.str();
}

string itoa(uint64_t n) {
    stringstream s;
    s << n;
    return s.str();
}

ComputeStore::ComputeStore() {
    // Initialize TM to all 0 entries
    TM = new uint64_t*[NSW];
	for (int i=0;i<NSW;i++){
		TM[i] = new uint64_t[NSW];
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
    R_all_traffic = new uint64_t[NSW];
    for (int i=0; i<NSW; i++) {
        R_all_traffic[i] = 0;
    } 
    R_out_traffic = new uint64_t[NSW];
    for (int i=0; i<NSW; i++) {
        R_out_traffic[i] = 0;
    }
    R_in_traffic = new uint64_t[NSW];
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

    // Initialize Dflow to 0
    Dflow = new double*[NSW];
	for (int i=0;i<NSW;i++){
		Dflow[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			Dflow[i][j] = 0;
		}
	}

    // Initialize DflowWithLinks to NULL
    DflowWithLinks = new route_t**[NSW];
	for (int i=0;i<NSW;i++){
		DflowWithLinks[i] = new route_t*[NSW];
		for (int j = 0;j<NSW;j++){
			DflowWithLinks[i][j] = NULL;
		}
	}

    // Initialize link_transit_rate to 0
    link_transit_rate = new double*[NSW];
	for (int i=0;i<NSW;i++){
		link_transit_rate[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			link_transit_rate[i][j] = 0;
		}
	}

    // Initialize link_transit_traffic to 0
    link_transit_traffic = new double*[NSW];
	for (int i=0;i<NSW;i++){
		link_transit_traffic[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			link_transit_traffic[i][j] = 0;
		}
	}

    // Initialize link_popularity to 0
    link_popularity = new double*[NSW];
	for (int i=0;i<NSW;i++){
		link_popularity[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			link_popularity[i][j] = 0;
		}
	}

    // Initialize rackBasedTraffic to 0
    rackBasedTraffic = new double[NSW];
	for (int i=0;i<NSW;i++){
		rackBasedTraffic[i] = 0;
	}
}

void ComputeStore::setRoutingScheme(string routing_, int korn_, string traffic_, string topology_) {
    routing = routing_;
    korn = korn_;
    traffic = traffic_;
    topology = topology_;
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
            int from, to;
            uint64_t bytes;
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
    string dir = traffic + "/";
    string filename = dir + traffic + "_tm_" + topology + ".txt";
    file.open(filename);
    int src_row_id, dst_column_id;
    uint64_t* row;
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

void ComputeStore::getRackBasedNetPath(string rfile) {
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
    cout << "topology file: " << rfile << endl;
    cout << "routing: " << routing << endl;
    cout << "korn = " << korn << endl;

    RandRegularTopology* top = new RandRegularTopology(&logfile, &eventlist, rfile, RANDOM, routing, korn);
    vector<route_t*>* available_paths_raw;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            available_paths_raw = top->get_paths(i, j).second;
            if (available_paths_raw->at(0)->size() == 0) assert(i == j);
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

    cout << "delete link_transit_rate" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] link_transit_rate[i];
    }	
    delete [] link_transit_rate;

    cout << "delete link_transit_traffic" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] link_transit_traffic[i];
    }	
    delete [] link_transit_traffic;

    cout << "delete link_popularity" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] link_popularity[i];
    }	
    delete [] link_popularity;

    cout << "delete rackBasedTraffic" << endl;	
    delete [] rackBasedTraffic;
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

int ComputeStore::getSrcIDfromLinkID(int linkID) {
    return linkID/NSW;
}

int ComputeStore::getDstIDfromLinkID(int linkID) {
    return linkID%NSW;
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

void ComputeStore::computeDNLinkTransitRateNRackBasedTraffic() {
    double** own_traffic = new double*[NSW];
	for (int i=0;i<NSW;i++){
		own_traffic[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			own_traffic[i][j] = 0;
		}
	}

    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            for (int k=0; k<LINKSIZE; k++) {
                if (net_link[i][j][k] > 0) {
                    D[k] += (net_link[i][j][k] * (double)TM[i][j]);
                    int link_src = getSrcIDfromLinkID(k);
                    int link_dst = getDstIDfromLinkID(k);
                    if (i==link_src || j==link_dst) {
                        own_traffic[link_src][link_dst] += (net_link[i][j][k] * (double)TM[i][j]);
                    }
                    rackBasedTraffic[link_src] += net_link[i][j][k] * (double)TM[i][j];
                    rackBasedTraffic[link_dst] += net_link[i][j][k] * (double)TM[i][j];
                }
            }
        }
    }

    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            link_transit_traffic[i][j] = D[i*NSW+j] - own_traffic[i][j];
            link_transit_rate[i][j] = (D[i*NSW+j] - own_traffic[i][j]) / D[i*NSW+j];
        }
    }

    for (int i=0; i<NSW; i++) {
	    delete [] own_traffic[i];
    }	
    delete [] own_traffic;
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
    double old_prob, new_prob;
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

    cout << "delete Dflow" << endl;
    for (int i=0; i<NSW; i++) {
	    delete [] Dflow[i];
    }	
    delete [] Dflow;

    cout << "delete DflowWithLinks" << endl;
    for (int i=0; i<NSW; i++) {
        // for (int j=0; j<NSW; j++) {
        //     if (DflowWithLinks[i][j] != NULL) delete DflowWithLinks[i][j];
        // }
        delete [] DflowWithLinks[i];
    }	
    delete [] DflowWithLinks;
}

void ComputeStore::storeD() {
    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_D_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "D\tlink src\tlink dst\ttransit traffic\ttransit rate\n";
    for (int i=0; i<LINKSIZE; i++) {
        if (D[i] > 0) {
            int link_src = getSrcIDfromLinkID(i);
            int link_dst = getDstIDfromLinkID(i);
            file << D[i] << "\t" << link_src << "\t" << link_dst << "\t" << link_transit_traffic[link_src][link_dst] << "\t" << link_transit_rate[link_src][link_dst] << "\n";
        }
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
    uint64_t sum, k;
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
    uint64_t in_sum;
    for (int j=0; j<NSW; j++) {
        in_sum = 0;
        for (int i=0; i<NSW; i++) {
            if (i!=j) in_sum += TM[i][j];
        }
        R_in_traffic[j] = in_sum;
    }

    // Compute R_out_traffic
    uint64_t out_sum;
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
    string dir = traffic + "/";
    string filename = dir + traffic + "_R_" + topology + "_" + routing + to_string(korn) + ".txt";
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

bool D_max_comparator(pair<int,double>D1, pair<int,double>D2) {
    return D1.second < D2.second;
}

bool D_min_comparator(pair<int,double>D1, pair<int,double>D2) {
    return D1.second > D2.second;
}

void ComputeStore::storeW(int limit) {
    priority_queue<pair<int,double>, vector< pair<int,double> >, function< bool(pair<int,double>, pair<int,double>)> > pq_max(D_max_comparator);
    for (int k=0; k<LINKSIZE; k++) {
        if (D[k] > 0) {
            pair<int,double> pr (k, D[k]);
            pq_max.push(pr);
        }
    }

    vector< pair<int,double> > max {};
    pair<int,double> max_pr;
    for (int a=0; a<limit; a++) {
        max_pr = pq_max.top();
        max.push_back(max_pr);
        pq_max.pop();
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
                    for (int l=0; l<net_path[i][j]->at(k)->size(); l=l+2) {
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
        string dir = traffic + "/";
        string filename = dir + traffic + "_W_max_" + to_string(a) + "_" + topology + "_" + routing + to_string(korn) + ".txt";
        file.open(filename);
        file << "Link source switch: " << src << ", destination switch: " << dst << ", total demand on the link = " << demand << "\n";
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

    priority_queue<pair<int,double>, vector< pair<int,double> >, function< bool(pair<int,double>, pair<int,double>)> > pq_min(D_min_comparator);
    for (int k=0; k<LINKSIZE; k++) {
        if (D[k] > 0) {
            pair<int,double> pr (k, D[k]);
            pq_min.push(pr);
        }
    }

    vector< pair<int,double> > min {};
    pair<int,double> min_pr;
    for (int a=0; a<limit; a++) {
        min_pr = pq_min.top();
        min.push_back(min_pr);
        pq_min.pop();
    }

    for (int a=0; a<limit; a++) {
        linkID = min.at(a).first;
        demand = min.at(a).second;
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
                    for (int l=0; l<net_path[i][j]->at(k)->size(); l=l+2) {
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
        string dir = traffic + "/";
        string filename = dir + traffic + "_W_" + to_string(a) + "_" + topology + "_" + routing + to_string(korn) + ".txt";
        file.open(filename);
        file << "Link source switch: " << src << ", destination switch: " << dst << ", total demand on the link = " << demand << "\n";
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

            uint64_t sum = 0;
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

void ComputeStore::computeNStoreRxIndexWithStats() {
    double* average_out_index_arr = new double[NSW];
    double* average_transit_index_arr = new double[NSW];
	for (int i=0;i<NSW;i++){
        average_out_index_arr[i] = 0;
        average_transit_index_arr[i] = 0;
	}

    for (int a=0; a<NSW; a++) {
        double demand = 0;
        uint64_t transit_traffic = (R_all_traffic[a] - R_out_traffic[a]);
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
    string dir = traffic + "/";
    string filename = dir + traffic + "_RxIndexWithStats_" + topology + "_" + routing + to_string(korn) + ".txt";
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
    string dir = traffic + "/";
    string filename = dir + traffic + "_index_" + topology + "_" + routing + to_string(korn) + ".txt";
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
    uint64_t* out_traffic_per_rack = new uint64_t[NSW];
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
        uint64_t out_traffic = 0;
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
    string dir = traffic + "/";
    string filename = dir + traffic + "_SWithStats_" + topology + "_" + routing + to_string(korn) + ".txt";
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

void ComputeStore::computeDflow() {
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i != j && TM[i][j] > 0) {
                int max_src_dst_pair = 0;
                route_t *max_route;
                for (int k=0; k<net_path[i][j]->size(); k++) {
                    route_t *path = net_path[i][j]->at(k);
                    int sum_path = 0;
                    for (int h=0; h<path->size(); h=h+2) {
                        string nodename = path->at(h)->nodename();
                        int link_id = getLinkID(nodename);
                        sum_path += D[link_id];
                    }
                    if (sum_path > max_src_dst_pair) {
                        max_src_dst_pair = sum_path;
                        max_route = path;
                    }
                }
                Dflow[i][j] = max_src_dst_pair;
                DflowWithLinks[i][j] = max_route;
            }
        }
    }
}

void ComputeStore::printDflow() {
    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_Dflow_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    int src_row_id, dst_column_id;
    double* row;
    for (int count=0; count<NSW; count++) {
        src_row_id = NSW - count - 1;
        row = Dflow[src_row_id];
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

void ComputeStore::printDflowWithLinks() {
    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_DflowWithLinks_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    int src_row_id, dst_column_id;
    route_t** row;
    for (int count=0; count<NSW; count++) {
        src_row_id = NSW - count - 1;
        row = DflowWithLinks[src_row_id];
        // cout << "src_row_id = " << src_row_id << endl;
        file << src_row_id << "\t";
        route_t *path;
        for (int dst_column_id=0; dst_column_id<NSW; dst_column_id++) {
            // cout << "dst_column_id = " << dst_column_id << endl;
            if (dst_column_id == src_row_id) {
                file << "\t";
            } else {
                path = row[dst_column_id];
                if (path == NULL || path->size()==0) {
                    file << "\t";
                } else {
                    file << "(";
                    for (int i=0; i<path->size(); i=i+2) {
                        // cout << "i = " << i << endl;
                        // cout << "path->size() = " << path->size() << endl;
                        string linkname = path->at(i)->nodename();
                        // cout << "linkname = " << linkname << endl;
                        file << extractSwitchID(linkname).first << "-" << extractSwitchID(linkname).second << " ";
                    }
                    // cout << "out of i" << endl;
                    file << ")\t";
                }
            }
        }
        // cout << "out of column" << endl;
        file << "\n";
    }
    // cout << "out of row" << endl;
    file << "\t";
    for (int i=0; i<NSW; i++) {
        file << i << "\t";
    }
    file.close();
}

// void ComputeStore::printDwithTraffic() {
//     ofstream file;
//     string dir = traffic + "/";
//     string filename = dir + traffic + "_DwithTraffic_rrg_" + routing + to_string(korn) + ".txt";
//     file.open(filename);
//     file << "D\tlink src\tlink dst\ttransit rate\tload\tprobability\tlxd\n";
//     for (int i=0; i<LINKSIZE; i++) {
//         if (D[i] > 0) {
//             int link_src = getSrcIDfromLinkID(i);
//             int link_dst = getDstIDfromLinkID(i);
//             file << D[i] << "\t" << link_src << "\t" << link_dst << "\t" << link_transit_rate[link_src][link_dst] << "\n";

//             for (int i=0; i<NSW; i++) {
//                 for (int j=0; j<NSW; j++) {
//                     for (int k=0; k<LINKSIZE; k++) {
//                         if (net_link[i][j][k] > 0) {
//                             file << "\t\t\t\t" << TM[i][j] << "\t" << net_link[i][j][k] << "\t" << net_link[i][j][k] * (double)TM[i][j] << "\n";
//                         }
//                     }
//                 }
//             }
//         }
//     }
//     file.close();
// }

void ComputeStore::computeLoadDistribution(int threshold, int upperbound) {
    double loadDistriA = 0, loadDistriB = 0, loadDistriC1 = 0, loadDistriC2 = 0;
    int numLinksA = 0, numLinksB = 0, numLinksC1 = 0, numLinksC2 = 0;

    for (int src=0; src<threshold; src++) {
        for (int dst=0; dst<threshold; dst++) {
            loadDistriA += D[src*NSW+dst];
            if (D[src*NSW+dst] > 0) numLinksA++;
        }
    }

    for (int src=threshold; src<upperbound; src++) {
        for (int dst=threshold; dst<upperbound; dst++) {
            loadDistriB += D[src*NSW+dst];
            if (D[src*NSW+dst] > 0) numLinksB++;
        }
    }

    for (int src=threshold; src<upperbound; src++) {
        for (int dst=0; dst<threshold; dst++) {
            loadDistriC1 += D[src*NSW+dst];
            if (D[src*NSW+dst] > 0) numLinksC1++;
        }
    }

    for (int src=0; src<threshold; src++) {
        for (int dst=threshold; dst<upperbound; dst++) {
            loadDistriC2 += D[src*NSW+dst];
            if (D[src*NSW+dst] > 0) numLinksC2++;
        }
    }

    cout << "Printing load distribution:" << endl;
    cout << "A = " << loadDistriA << " with #link = " << numLinksA << endl;
    cout << "B = " << loadDistriB << " with #link = " << numLinksB << endl;
    cout << "C1 = " << loadDistriC1 << " with #link = " << numLinksC1 << endl;
    cout << "C2 = " << loadDistriC2 << " with #link = " << numLinksC2 << endl;
}

void ComputeStore::computeNPrintLinkPopularity(int lower1, int upper1, int lower2, int upper2, bool bidirectional) {
    for (int i=lower1; i<upper1; i++) {
        for (int j=lower2; j<upper2; j++) {
            int count = net_path[i][j]->size();
            if (count == 1 && net_path[i][j]->at(0)->size() == 0) count = 0; 
            for (int k=0; k<count; k++) {
                for (int l=0; l<net_path[i][j]->at(k)->size(); l=l+2) {
                    string nodename = net_path[i][j]->at(k)->at(l)->nodename();
                    int srcID = extractSwitchID(nodename).first;
                    int dstID = extractSwitchID(nodename).second;
                    link_popularity[srcID][dstID] += 1.0/(double)count;
                }
            }
        }
    }

    if (bidirectional) {
        for (int i=lower2; i<upper2; i++) {
            for (int j=lower1; j<upper1; j++) {
                int count = net_path[i][j]->size();
                if (count == 1 && net_path[i][j]->at(0)->size() == 0) count = 0; 
                for (int k=0; k<count; k++) {
                    for (int l=0; l<net_path[i][j]->at(k)->size(); l=l+2) {
                        string nodename = net_path[i][j]->at(k)->at(l)->nodename();
                        int srcID = extractSwitchID(nodename).first;
                        int dstID = extractSwitchID(nodename).second;
                        link_popularity[srcID][dstID] += 1.0/(double)count;
                    }
                }
            }
        }
    }

    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_linkPopularity_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "link popularity\tlink src\tlink dst\n";
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (link_popularity[i][j] > 0) {
                file << link_popularity[i][j] << "\t" << i << "\t" << j << "\n";
            }
        }
    }
    file.close();
}

void ComputeStore::printRackBasedTraffic() {
    double* in_traffic = new double[NSW];
    double* out_traffic = new double[NSW];
    for (int i=0; i<NSW; i++) {
        in_traffic[i] = 0;
        out_traffic[i] = 0;
    }

    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            out_traffic[i] += TM[i][j];
            in_traffic[j] += TM[i][j];
        }
    }

    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_rackBasedTraffic_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "rackID\ttotal traffic\ttransit traffic\ttransit rate\tout traffic\tin traffic\n";
    for (int i=0; i<NSW; i++) {
        double transit_traffic = rackBasedTraffic[i] - in_traffic[i] - out_traffic[i];
        file << i << "\t" << rackBasedTraffic[i] << "\t" << transit_traffic << "\t" << transit_traffic/rackBasedTraffic[i] << "\t" << out_traffic[i] << "\t" << in_traffic[i] << "\n";
    }
    file.close(); 

    delete [] in_traffic;
    delete [] out_traffic;
}

// Default: centered on the out traffic, but this does not have to be true
void ComputeStore::computeNPrintLinkPopularitySingleRow(int targetRack) {
    double** link_popularity_out = new double*[NSW];
    double** link_popularity_in = new double*[NSW];
    double** link_popularity_transit = new double*[NSW];
	for (int i=0;i<NSW;i++){
		link_popularity_out[i] = new double[NSW];
        link_popularity_in[i] = new double[NSW];
        link_popularity_transit[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			link_popularity_out[i][j] = 0;
            link_popularity_in[i][j] = 0;
            link_popularity_transit[i][j] = 0;
		}
	}

    // targetRack -> dst
    for (int j=0; j<NSW; j++) {
        int count = net_path[targetRack][j]->size();
        if (count == 1 && net_path[targetRack][j]->at(0)->size() == 0) count = 0; 
        for (int k=0; k<count; k++) {
            for (int l=0; l<net_path[targetRack][j]->at(k)->size(); l=l+2) {
                string nodename = net_path[targetRack][j]->at(k)->at(l)->nodename();
                int srcID = extractSwitchID(nodename).first;
                int dstID = extractSwitchID(nodename).second;
                link_popularity_out[srcID][dstID] += 1.0/(double)count;
            }
        }
    }

    // src -> targetRack
    for (int i=0; i<NSW; i++) {
        int count = net_path[i][targetRack]->size();
        if (count == 1 && net_path[i][targetRack]->at(0)->size() == 0) count = 0; 
        for (int k=0; k<count; k++) {
            for (int l=0; l<net_path[i][targetRack]->at(k)->size(); l=l+2) {
                string nodename = net_path[i][targetRack]->at(k)->at(l)->nodename();
                int srcID = extractSwitchID(nodename).first;
                int dstID = extractSwitchID(nodename).second;
                link_popularity_in[srcID][dstID] += 1.0/(double)count;
            }
        }
    }

    // src -> targetRack -> dst
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i != targetRack && j != targetRack) {
                int count = net_path[i][j]->size();
                if (count == 1 && net_path[i][j]->at(0)->size() == 0) count = 0; 
                for (int k=0; k<count; k++) {
                    for (int l=0; l<net_path[i][j]->at(k)->size(); l=l+2) {
                        string nodename = net_path[i][j]->at(k)->at(l)->nodename();
                        int srcID = extractSwitchID(nodename).first;
                        int dstID = extractSwitchID(nodename).second;
                        if (srcID == targetRack || dstID == targetRack) {
                            link_popularity_transit[srcID][dstID] += 1.0/(double)count;
                        }
                    }
                }                
            }
        }
    }

    uint64_t out_traffic = 0, in_traffic = 0, transit_traffic = 0;
    double in_to_out_TM_ratio = 0, transit_to_out_TM_ratio = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i == targetRack && j == targetRack) {
                // do nothing
            } else if (i == targetRack) {
                // targetRack -> dst; out traffic
                out_traffic += TM[i][j];
            } else if (j == targetRack) {
                // src -> targetRack; in traffic
                in_traffic += TM[i][j];
            } else {
                transit_traffic += TM[i][j];
            }
        }
    }
    in_to_out_TM_ratio = (double)in_traffic / out_traffic;
    transit_to_out_TM_ratio = (double)transit_traffic / out_traffic;

    cout << "ComputeNPrintLinkPopularitySingleRow:" << endl;
    cout << "in_traffic/out_traffic = " << in_to_out_TM_ratio << endl;
    cout << "transit_traffic/out_traffic = " << transit_to_out_TM_ratio << endl;

    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_singleRowLinkPopularity_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "link popularity\tlink src\tlink dst\tout\tin\tin/out\ttransit\ttransit/out\n";
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            double pop = link_popularity_out[i][j] + link_popularity_in[i][j]*in_to_out_TM_ratio + link_popularity_transit[i][j]*transit_to_out_TM_ratio;
            if (pop > 0) {
                file << pop << "\t" << i << "\t" << j << "\t";
                file << link_popularity_out[i][j] << "\t";
                file << link_popularity_in[i][j] << "\t" << in_to_out_TM_ratio << "\t";
                file << link_popularity_transit[i][j] << "\t" << transit_to_out_TM_ratio << "\n";
            }
        }
    }
    file.close(); 

    for (int i=0; i<NSW; i++) {
	    delete [] link_popularity_out[i];
        delete [] link_popularity_in[i];
        delete [] link_popularity_transit[i];
    }	
    delete [] link_popularity_out;
    delete [] link_popularity_in;
    delete [] link_popularity_transit;
}

void ComputeStore::computeNPrintLinkPopularityGeneral() {
    double** link_popularity_out = new double*[NSW];
    double** link_popularity_in = new double*[NSW];
    double** link_popularity_transit = new double*[NSW];
	for (int i=0;i<NSW;i++){
		link_popularity_out[i] = new double[NSW];
        link_popularity_in[i] = new double[NSW];
        link_popularity_transit[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			link_popularity_out[i][j] = 0;
            link_popularity_in[i][j] = 0;
            link_popularity_transit[i][j] = 0;
		}
	}

    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i == j) continue;
            int count = net_path[i][j]->size();
            if (count == 1 && net_path[i][j]->at(0)->size() == 0) count = 0; 
            for (int k=0; k<count; k++) {
                int size = net_path[i][j]->at(k)->size();
                for (int l=0; l<size; l=l+2) {
                    string nodename = net_path[i][j]->at(k)->at(l)->nodename();
                    int srcID = extractSwitchID(nodename).first;
                    int dstID = extractSwitchID(nodename).second;
                    if (l==0) {
                        assert(srcID == i);
                        link_popularity_out[srcID][dstID] += 1.0/(double)count;
                    } else if (l+2>=size) {
                        assert(dstID == j);
                        link_popularity_in[srcID][dstID] += 1.0/(double)count;
                    } else {
                        link_popularity_transit[srcID][dstID] += 1.0/(double)count;
                    }
                }
            }                
        }
    }

    uint64_t* in_traffic = new uint64_t[NSW];
    uint64_t* out_traffic = new uint64_t[NSW];
	for (int i=0;i<NSW;i++){
		in_traffic[i] = 0;
        out_traffic[i] = 0;
	}
    uint64_t sum_traffic = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i == j) continue;
            sum_traffic += TM[i][j];
            in_traffic[j] += TM[i][j];
            out_traffic[i] += TM[i][j];
        }
    }
    cout << "sum traffic = " << sum_traffic << endl;

    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_generalLinkPopularity_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "link popularity\tlink src\tlink dst\tout pop\tout traffic\tin pop\tin traffic\ttransit pop\ttransit/sum traffic\n";
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            double pop = link_popularity_out[i][j]*(out_traffic[i]/(double)sum_traffic) + link_popularity_in[i][j]*(in_traffic[j]/(double)sum_traffic) + link_popularity_transit[i][j];
            if (pop > 0) {
                file << pop << "\t" << i << "\t" << j << "\t";
                file << link_popularity_out[i][j] << "\t" << out_traffic[i] << "\t";
                file << link_popularity_in[i][j] << "\t" << in_traffic[j] << "\t";
                file << link_popularity_transit[i][j] << "\t" << sum_traffic << "\n";
            }
        }
    }
    file.close(); 

    for (int i=0; i<NSW; i++) {
	    delete [] link_popularity_out[i];
        delete [] link_popularity_in[i];
        delete [] link_popularity_transit[i];
    }	
    delete [] link_popularity_out;
    delete [] link_popularity_in;
    delete [] link_popularity_transit;   
    delete [] in_traffic;
    delete [] out_traffic;
}

void ComputeStore::computeNPrintRackPopularity() {
    double** link_popularity_out = new double*[NSW];
    double** link_popularity_in = new double*[NSW];
    double** link_popularity_transit = new double*[NSW];
	for (int i=0;i<NSW;i++){
		link_popularity_out[i] = new double[NSW];
        link_popularity_in[i] = new double[NSW];
        link_popularity_transit[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			link_popularity_out[i][j] = 0;
            link_popularity_in[i][j] = 0;
            link_popularity_transit[i][j] = 0;
		}
	}

    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i == j) continue;
            int count = net_path[i][j]->size();
            if (count == 1 && net_path[i][j]->at(0)->size() == 0) count = 0; 
            for (int k=0; k<count; k++) {
                int size = net_path[i][j]->at(k)->size();
                for (int l=0; l<size; l=l+2) {
                    string nodename = net_path[i][j]->at(k)->at(l)->nodename();
                    int srcID = extractSwitchID(nodename).first;
                    int dstID = extractSwitchID(nodename).second;
                    if (l==0) {
                        assert(srcID == i);
                        link_popularity_out[srcID][dstID] += 1.0/(double)count;
                    } else if (l+2>=size) {
                        assert(dstID == j);
                        link_popularity_in[srcID][dstID] += 1.0/(double)count;
                    } else {
                        link_popularity_transit[srcID][dstID] += 1.0/(double)count;
                    }
                }
            }                
        }
    }

    double* rack_popularity_out = new double[NSW];
    double* rack_popularity_in = new double[NSW];
    double* rack_popularity_transit = new double[NSW];
	for (int i=0;i<NSW;i++){
		rack_popularity_out[i] = 0;
        rack_popularity_in[i] = 0;
        rack_popularity_transit[i] = 0;
	}
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i == j) continue;
            rack_popularity_out[i] += link_popularity_out[i][j];
            rack_popularity_in[j] += link_popularity_in[i][j];
            rack_popularity_transit[j] += (link_popularity_transit[i][j] + link_popularity_transit[j][i]);
        }
    } 

    uint64_t* in_traffic = new uint64_t[NSW];
    uint64_t* out_traffic = new uint64_t[NSW];
	for (int i=0;i<NSW;i++){
		in_traffic[i] = 0;
        out_traffic[i] = 0;
	}
    uint64_t sum_traffic = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i == j) continue;
            sum_traffic += TM[i][j];
            in_traffic[j] += TM[i][j];
            out_traffic[i] += TM[i][j];
        }
    }

    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_rackPopularity_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "rack popularity\track ID\tout pop\tout traffic\tin pop\tin traffic\ttransit pop\ttransit/sum traffic\n";
    for (int i=0; i<NSW; i++) {
        double pop = (rack_popularity_out[i]*out_traffic[i] + rack_popularity_in[i]*in_traffic[i] + rack_popularity_transit[i]*sum_traffic) / sum_traffic;
        if (pop > 0) {
            file << pop << "\t" << i << "\t";
            file << rack_popularity_out[i] << "\t" << out_traffic[i] << "\t";
            file << rack_popularity_in[i] << "\t" << in_traffic[i] << "\t";
            file << rack_popularity_transit[i] << "\t" << sum_traffic << "\n";
        }
    }
    file.close(); 

    for (int i=0; i<NSW; i++) {
	    delete [] link_popularity_out[i];
        delete [] link_popularity_in[i];
        delete [] link_popularity_transit[i];
    }	
    delete [] link_popularity_out;
    delete [] link_popularity_in;
    delete [] link_popularity_transit;   
    delete [] rack_popularity_out;
    delete [] rack_popularity_in;
    delete [] rack_popularity_transit;   
    delete [] in_traffic;
    delete [] out_traffic;    
}

void ComputeStore::computeNPrintLinkPopularitySuperLink() {
    // type A traffic: 60-64 <=> 0-59 (lesser)
    // type B traffic: 65-79 <=> 0-59
    // other traffic: everything else
    double** type_A_link_popularity = new double*[NSW];
    double** type_B_link_popularity = new double*[NSW];
    double** other_link_popularity = new double*[NSW];
	for (int i=0;i<NSW;i++){
		type_A_link_popularity[i] = new double[NSW];
        type_B_link_popularity[i] = new double[NSW];
        other_link_popularity[i] = new double[NSW];
		for (int j = 0;j<NSW;j++){
			type_A_link_popularity[i][j] = 0;
            type_B_link_popularity[i][j] = 0;
            other_link_popularity[i][j] = 0;
		}
	}

    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            int count = net_path[i][j]->size();
            if (count == 1 && net_path[i][j]->at(0)->size() == 0) count = 0; 
            for (int k=0; k<count; k++) {
                for (int l=0; l<net_path[i][j]->at(k)->size(); l=l+2) {
                    string nodename = net_path[i][j]->at(k)->at(l)->nodename();
                    int srcID = extractSwitchID(nodename).first;
                    int dstID = extractSwitchID(nodename).second;
                    if ((i<62 && 62<=j && j<67) || (j<62 && 62<=i && i<67)) {
                        type_A_link_popularity[srcID][dstID] += 1.0/(double)count;
                    } else if ((i<62 && 67<=j && j<80) || (j<62 && 67<=i && i<80)) {
                        type_B_link_popularity[srcID][dstID] += 1.0/(double)count;
                    } else {
                        other_link_popularity[srcID][dstID] += 1.0/(double)count;
                    }
                    
                }
            }
        }
    }

    uint64_t type_A_traffic = 0;
    uint64_t type_B_traffic = 0;
    uint64_t other_traffic = 0;
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            if (i == j) continue;
            if (((62<=i && i<67) && (j<62)) || ((62<=j && j<67) && (i<62))) {
                type_A_traffic += TM[i][j];
            } else if (((67<=i && i<80) && (j<62)) || ((67<=j && j<80) && (i<62))) {
                type_B_traffic += TM[i][j];
            } else {
                other_traffic += TM[i][j];
            }
        }
    }

    ofstream file;
    string dir = traffic + "/";
    string filename = dir + traffic + "_superLinkPopularity_" + topology + "_" + routing + to_string(korn) + ".txt";
    file.open(filename);
    file << "link popularity\tlink src\tlink dst\ttype A pop\ttype A traffic\ttype B pop\ttype B traffic\tother pop\tother traffic\n";
    for (int i=0; i<NSW; i++) {
        for (int j=0; j<NSW; j++) {
            double pop = type_A_link_popularity[i][j]*(type_A_traffic/type_B_traffic) + type_B_link_popularity[i][j] + other_link_popularity[i][j]*(other_traffic/type_B_traffic);
            file << pop << "\t" << i << "\t" << j << "\t";
            file << type_A_link_popularity[i][j] << "\t" << type_A_traffic << "\t";
            file << type_B_link_popularity[i][j] << "\t" << type_B_traffic << "\t";
            file << other_link_popularity[i][j] << "\t" << other_traffic << "\n";
        }
    }
    file.close();

    for (int i=0; i<NSW; i++) {
	    delete [] type_A_link_popularity[i];
        delete [] type_B_link_popularity[i];
        delete [] other_link_popularity[i];
    }	
    delete [] type_A_link_popularity;
    delete [] type_B_link_popularity;
    delete [] other_link_popularity;
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
