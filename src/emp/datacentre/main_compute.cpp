#include "compute_store.h"

int main(int argc, char **argv) {
    ComputeStore* store = new ComputeStore();
    store->getRackBasedTM("graphfiles/ring_supergraph/ls_x48_y16_skewed.data");
    store->storeRackBasedTM();
}