#ifndef MAIN_H
#define MAIN_H

#include <string>

#define HOST_NIC 894784 // host nic speed in pps
#define CORE_TO_HOST 10
#define NUMPATHS 16

#define NSW 80	
#define NHOST 3072

#define OVERSUBSCRIPTION 1

// RRG STUFF
#define R 		// R = switch-switch ports (or network-ports)
#define SP 64		// P = total ports on switch

// FAT
#define K 64

// TOPOLOGY NUMBERING
#define FAT 0
#define RRG 1
#define LEAFSPINE 2

// CHOSEN TOPOLOGY
#define CHOSEN_TOPO RRG

//basic setup!

#define NI 2        //Number of intermediate switches
#define NA 6        //Number of aggregation switches
#define NT 9        //Number of ToR switches (180 hosts)

#define NS 20        //Number of servers per ToR switch
#define TOR_AGG2(tor) (10*NA - tor - 1)%NA

/*
#define NI 4        //Number of intermediate switches
#define NA 9        //Number of aggregation switches
#define NT 18        //Number of ToR switches (180 hosts)

#define NS 10        //Number of servers per ToR switch
#define TOR_AGG2(tor) (tor+1)%NA
*/
/*
#define NI 10        //Number of intermediate switches
#define NA 6        //Number of aggregation switches
#define NT 30        //Number of ToR switches (180 hosts)

#define NS 6        //Number of servers per ToR switch
#define TOR_AGG2(tor) (tor+1)%NA
*/

#define NT2A 2      //Number of connections from a ToR to aggregation switches

#define TOR_ID(id) NSW+id
#define AGG_ID(id) NSW+NT+id
#define INT_ID(id) NSW+NT+NA+id
#define HOST_ID(hid,tid) tid*NS+hid

#define HOST_TOR(host) host/NS
#define HOST_TOR_ID(host) host%NS
#define TOR_AGG1(tor) tor%NA


#define SWITCH_BUFFER 100
#define RANDOM_BUFFER 3
#define FEEDER_BUFFER 100

#endif
