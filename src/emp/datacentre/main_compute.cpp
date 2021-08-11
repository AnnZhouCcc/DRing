#include <sstream>
#include <iostream>
#include "compute_store.h"

uint32_t RTT = 2;

int main(int argc, char **argv) {
    ComputeStore* store = new ComputeStore();
    // store->getRackBasedTM("graphfiles/ring_supergraph/ls_x48_y16_skewed.data");
    // store->storeRackBasedTM();
    store->getRackBasedNetPath();
    // store->checkRackBasedNetPath(5);
    store->getNetLinkNetSumNetCount();
    // store->checkNetLink(5);
    // store->checkNetSumNetCount(5);
    store->computeD();
    store->outputD();
    store->computeT();
    int plen = store->computePlen();
    int e = 0;
    int ne = store->computeNe(e);
    cout << "plen = " << plen << ", ne = " << ne << " (e = " << e << ")" << endl;
    store->deleteComputations();
    store->deleteMatrices();  
}

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
