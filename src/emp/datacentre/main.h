#ifndef MAIN_H
#define MAIN_H

#include <string>

#define HOST_NIC 894784 // host nic speed in pps
#define NSW 80	
#define NHOST 3072
#define OVERSUBSCRIPTION 1

// FAT
#define K 64

// TOPOLOGY NUMBERING
#define FAT 0
#define RRG 1
#define LEAFSPINE 2

// CHOSEN TOPOLOGY
#define CHOSEN_TOPO LEAFSPINE

#define SWITCH_BUFFER 100
#define RANDOM_BUFFER 3
#define FEEDER_BUFFER 100

#endif
