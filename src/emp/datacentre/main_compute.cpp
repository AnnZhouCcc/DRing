#include <sstream>
#include <iostream>
#include "compute_store.h"

uint32_t RTT = 2;

int main(int argc, char **argv) {
    string TMfile = "graphfiles/ring_supergraph/ls_x48_y16_skewed.data";
    // string TMfile = "graphfiles/ring_supergraph/ls_rand_placed_x48_y16_uniform.data";
    string traffic = "fb_skewed";
    string routing = "kshort";
    int korn = 16;
    string topology = "dring"; // need to change run_compute.sh too
    string rfile = "graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist";
    ComputeStore* store = new ComputeStore();
    store->setRoutingScheme(routing, korn, traffic, topology);
    store->getRackBasedTM(TMfile);
    // store->storeRackBasedTM();
    store->getRackBasedNetPath(rfile);
    // store->storeRackBasedNetPath(3);
    store->getNetLinkNetSumNetCount();
    // store->storeNetLink(5);
    // store->checkNetSumNetCount(5);
    // store->computeDNLinkTransitRateNRackBasedTraffic();
    // store->storeD();
    // store->printDwithTraffic();
    // store->computeT();
    // store->checkValidity();
    // double plen = store->computePlen();
    // double e = 0.01;
    // int ne = store->computeNe(e);
    // cout << "plen = " << plen << ", ne = " << ne << " (e = " << e << ")" << endl;
    // store->computeR();
    // store->storeR();
    // store->storeW(5);
    // store->computeLoadDistribution(65, 80);
    // store->computeNPrintLinkPopularity(0, 65, 65, 80, true);
    // store->computeNPrintLinkPopularitySingleRow(79);
    // store->computeNPrintLinkPopularityGeneral();
    store->computeNPrintLinkPopularitySuperLink();
    // store->printRackBasedTraffic();
    // store->computeNPrintRackPopularity();

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

    // store->computeDflow();
    // store->printDflow();
    // store->printDflowWithLinks();

    store->deleteComputations();
    store->deletePathIndex();
    store->deleteMatrices();  
}

