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
        void setRoutingScheme(string routing_, int korn_);
        int convertHostToSwitch(int host);
        void getRackBasedTM(string filename);
        void storeRackBasedTM();
        void getRackBasedNetPath();
        void storeRackBasedNetPath(int limit);
        void deleteMatrices();
	void deleteTM();
        void getNetLinkNetSumNetCount();
        void storeNetLink(int limit);
        void storeNetSumNetCount(int limit);
        void computeD();
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
        void computeRxIndex();
        void storeRxIndex();
        void storeIndex();
        void computeNStoreRxIndexWithStats();
        void computeNStoreSWithStats();
    
    private:
        string routing;
        int korn;
        int** TM;
        double*** net_link;
        int** net_sum;
        int** more_than_one_hop_net_count;
        int** net_count;
        double* D;
        double*** T;
        double plen;
        int Ne;
        int* R_all_traffic;
        int* R_out_traffic;
        int* R_in_traffic;
        double** W;
        double** first_hop_index;
        double** non_first_hop_index;
        double* RxIndex;
        int total_TM;
        double average_path_length;
        double** percentage;
        double percentage_traffic_requiring_transit;
        double* S;

        pair<int, int> extractSwitchID(string nodename);
        int getLinkID(string nodename);

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
