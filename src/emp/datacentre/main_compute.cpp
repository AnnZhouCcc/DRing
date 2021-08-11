#include <sstream>
#include "compute_store.h"

uint32_t RTT = 2;

int main(int argc, char **argv) {
    ComputeStore* store = new ComputeStore();
    // store->getRackBasedTM("graphfiles/ring_supergraph/ls_x48_y16_skewed.data");
    // store->storeRackBasedTM();
    store->getRackBasedNetPath();
    store->checkRackBasedNetPath(5);
    store->deleteNetPath();    
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
