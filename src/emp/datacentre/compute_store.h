#ifndef compute_store
#define compute_store

#include <string.h>
#include "route.h"

// Hardcoding number of switches, ports for now -- Copied from connection_matrix.h
#define REDUCED_NHOST (NHOST/OVERSUBSCRIPTION)
#define SVRPORTS (OVERSUBSCRIPTION * (REDUCED_NHOST%NSW==0?REDUCED_NHOST/NSW:REDUCED_NHOST/NSW+1))
#define HETERO (REDUCED_NHOST%NSW==0?0:1)

class ComputeStore {
    public: 
        ComputeStore();
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
    
    private:
        int** TM;
        vector<route_t*>*** net_path;
        double*** net_link;
        int** net_sum;
        int** net_count;
        double* D;
        double*** T;
        double plen;
        int Ne;
        int* R_all_traffic;
        int* R_out_traffic;
        int* R_in_traffic;
        double** W;

        pair<int, int> extractSwitchID(string nodename);
        int getLinkID(string nodename);
};

#endif
