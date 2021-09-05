#ifndef compute_store
#define compute_store

#include <string.h>
#include <map>
#include "route.h"

// Hardcoding number of switches, ports for now -- Copied from connection_matrix.h
#define REDUCED_NHOST (NHOST/OVERSUBSCRIPTION)
#define SVRPORTS (OVERSUBSCRIPTION * (REDUCED_NHOST%NSW==0?REDUCED_NHOST/NSW:REDUCED_NHOST/NSW+1))
#define HETERO (REDUCED_NHOST%NSW==0?0:1)

class ComputeStore {
    public: 
        vector<route_t*>*** net_path;

        ComputeStore();
        void setRoutingScheme(string routing_, int korn_, string traffic_, string topology_);
        int convertHostToSwitch(int host);
        void getRackBasedTM(string filename);
        void storeRackBasedTM();
        void getRackBasedNetPath(string rfile);
        void storeRackBasedNetPath(int limit);
        void deleteMatrices();
	void deleteTM();
        void getNetLinkNetSumNetCount();
        void storeNetLink(int limit);
        void storeNetSumNetCount(int limit);
        void computeDNLinkTransitRateNRackBasedTraffic();
        void computeT();
        void deleteComputations();
        double computePlen();
        int computeNe(double e);
        void storeD();
        void checkValidity();
        void computeR();
        void storeR();
        void storeW(int limit);
        void computeIndex();
        void deletePathIndex();
        void storeIndex();
        void computeNStoreRxIndexWithStats();
        void computeNStoreSWithStats();

        void computeDflow();
        void printDflow();
        void printDflowWithLinks();
        // void printDwithTraffic();

        void computeLoadDistribution(int threshold, int upperbound);
        void computeNPrintLinkPopularity(int lower1, int upper1, int lower2, int upper2, bool bidirectional);
        void printRackBasedTraffic();
        void computeNPrintLinkPopularitySingleRow(int targetRack);
        void computeNPrintLinkPopularityGeneral();
        void computeNPrintLinkPopularitySuperLink();
        void computeNPrintRackPopularity();
    
    private:
        string routing;
        int korn;
        string traffic;
        string topology;
        uint64_t** TM;
        double*** net_link;
        double** link_transit_rate;
        double** link_transit_traffic;
        double** link_popularity;
        int** net_sum;
        int** more_than_one_hop_net_count;
        int** net_count;
        double* D;
        double*** T;
        double plen;
        int Ne;
        uint64_t* R_all_traffic;
        uint64_t* R_out_traffic;
        uint64_t* R_in_traffic;
        double** W;
        double** first_hop_index;
        double** non_first_hop_index;
        double* RxIndex;
        uint64_t total_TM;
        double average_path_length;
        double** percentage;
        double percentage_traffic_requiring_transit;
        double* S;

        double** Dflow;
        route_t*** DflowWithLinks;
        double* rackBasedTraffic;

        pair<int, int> extractSwitchID(string nodename);
        int getLinkID(string nodename);
        int getSrcIDfromLinkID(int linkID);
        int getDstIDfromLinkID(int linkID);

    friend class PathGraph;
};

class PathItem {
    public:
        int id;
        double load;
};

class PathNode : public PathItem {
    public:
        PathNode();
        // int id;
        // double load;
        vector<PathItem *> incoming_edges;
        vector<PathItem *> outgoing_edges;
};

class PathEdge : public PathItem {
    public:
        PathEdge();
        // int id;
        // double load;
        int weight;
        PathNode *from;
        PathNode *to;
        bool visited;
};

class PathGraph {
    public:
        PathGraph(int src, int dst, ComputeStore *computestore);
        void printNetPath();
        void printGraph();
        // void computeIndex(int source_load);
        double computeIndex();

        ComputeStore *store;
        vector<route_t *> *available_paths;
        map<string, PathEdge *> route_edge_map;
        map<int, PathNode *> id_node_map;
        map<int, PathEdge *> id_edge_map;
        int graph_src_id;
        int graph_dst_id;
        double index;
};

#endif
