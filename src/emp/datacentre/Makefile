CC = g++
CFLAGS = -std=c++11 -O3 -w -Wall -Wno-deprecated -Wno-unused-variable
#CFLAGS = -std=c++11 -g -w -Wall -Wno-deprecated -Wno-unused-variable
#CRT_space=$(shell pwd) #`pwd`
#CRT=$(strip $(CRT_space))

# BASEDIR=/home/annzhou/DRing/src/emp
BASEDIR=/Users/annzhou/research/uiuc/DRing/src/emp
CRT=$(BASEDIR)/datacentre
# GRB=/home/annzhou/gurobi912/linux64/include
GRB=/Library/gurobi911/mac64/include
CRT_1UP=$(BASEDIR)
INCLUDE= -I/$(CRT_1UP) -I$(CRT) -I$(GRB)
#-I$(CRT)/ksp -I$(CRT)/ksp/boost
# GRBLIB=/home/annzhou/gurobi912/linux64/lib
GRBLIB=/Library/gurobi911/mac64/lib
LIB=-L.. -L${GRBLIB}
#-Lksp

all:	fattree rrg leafspine computestore storetm

#Leaf spine
leafspine: main_flowsize.o ../libhtsim.a leaf_spine_topology.o connection_matrix.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o
	$(CC) $(INCLUDE) $(CFLAGS)  main_flowsize.o leaf_spine_topology.o connection_matrix.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o $(LIB) -lhtsim -o leafspine

fattree: main_flowsize.o  ../libhtsim.a fat_tree_topology.o connection_matrix.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o
	$(CC) $(INCLUDE) $(CFLAGS)  main_flowsize.o fat_tree_topology.o connection_matrix.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o $(LIB) -lhtsim -o fattree

# -lgurobi_g++5.2
rrg: main_flowsize.o  ../libhtsim.a connection_matrix.o rand_regular_topology.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o
	$(CC) $(INCLUDE) $(CFLAGS)  main_flowsize.o connection_matrix.o rand_regular_topology.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o $(LIB) -lhtsim -lgurobi_g++4.2 -lgurobi91 -o rrg

computestore: main_compute.o  ../libhtsim.a compute_store.o connection_matrix.o rand_regular_topology.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o
	$(CC) $(INCLUDE) $(CFLAGS)  main_compute.o compute_store.o connection_matrix.o rand_regular_topology.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o $(LIB) -lhtsim -lgurobi_g++4.2 -lgurobi91 -o computestore

storetm: main_storetm.o  ../libhtsim.a connection_matrix.o rand_regular_topology.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o
	$(CC) $(INCLUDE) $(CFLAGS)  main_storetm.o connection_matrix.o rand_regular_topology.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o $(LIB) -lhtsim -lgurobi_g++4.2 -lgurobi91 -o storetm

main_flowsize.o: main_flowsize.cpp main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c main_flowsize.cpp 

main_compute.o: main_compute.cpp main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c main_compute.cpp 

main_storetm.o: main_storetm.cpp main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c main_storetm.cpp

compute_store.o: compute_store.cpp compute_store.h main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c compute_store.cpp

connection_matrix.o: connection_matrix.cpp main.h 
	$(CC) $(INCLUDE) $(CFLAGS) -c connection_matrix.cpp 

leaf_spine_topology.o: leaf_spine_topology.cpp leaf_spine_topology.h topology.h  main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c leaf_spine_topology.cpp

fat_tree_topology.o: fat_tree_topology.cpp fat_tree_topology.h topology.h  main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c fat_tree_topology.cpp

rand_regular_topology.o: rand_regular_topology.cpp rand_regular_topology.h topology.h Graph.h GraphElements.h main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c rand_regular_topology.cpp

DijkstraShortestPathAlg.o: DijkstraShortestPathAlg.cpp DijkstraShortestPathAlg.h
	$(CC) $(INCLUDE) $(CFLAGS) -c DijkstraShortestPathAlg.cpp

Graph.o: Graph.cpp Graph.h GraphElements.h main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c Graph.cpp

YenTopKShortestPathsAlg.o: YenTopKShortestPathsAlg.cpp YenTopKShortestPathsAlg.h
	$(CC) $(INCLUDE) $(CFLAGS) -c YenTopKShortestPathsAlg.cpp

BhandariTopKDisjointPathsAlg.o: BhandariTopKDisjointPathsAlg.cpp BhandariTopKDisjointPathsAlg.h
	$(CC) $(INCLUDE) $(CFLAGS) -c BhandariTopKDisjointPathsAlg.cpp

clean:	
	rm *.o htsim_dc rrg fattree leafspine computestore storetm
