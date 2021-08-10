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
    
    private:
        int** TM;

};

#endif