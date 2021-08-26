#include <sstream>
#include <iostream>
#include "compute_store.h"

uint32_t RTT = 2;

int main(int argc, char **argv) {
    string TMfile = "graphfiles/ring_supergraph/ls_x48_y16_skewed.data";
    string routing = "kshort";
    int korn = 16;
    ComputeStore* store = new ComputeStore();
    store->setRoutingScheme(routing, korn);
    store->getRackBasedTM(TMfile);
    // store->storeRackBasedTM();
    store->getRackBasedNetPath();
    // store->storeRackBasedNetPath(3);
    store->getNetLinkNetSumNetCount();
    // store->storeNetLink(5);
    // store->checkNetSumNetCount(5);
    store->computeD();
    // store->storeD();
    // store->computeT();
    // store->checkValidity();
    // double plen = store->computePlen();
    // double e = 0.01;
    // int ne = store->computeNe(e);
    // cout << "plen = " << plen << ", ne = " << ne << " (e = " << e << ")" << endl;
    store->computeR();
    store->storeR();
    store->storeW(5);

    // store->computeIndex();
    // store->computeRxIndex();
    // store->storeRxIndex();
    // store->computeNStoreRxIndexWithStats();
    // store->computeNStoreSWithStats();

    // int src = 0;
    // int dst = 1;
    // int source_load = 100;
    // PathGraph *graph = new PathGraph(src, dst, store);
    // graph->computeIndex(source_load);
    // cout << "index = " << index << endl;
    // graph->printNetPath();
    // graph->printGraph();

    store->deleteComputations();
    store->deletePathIndex();
    store->deleteMatrices();  
}

