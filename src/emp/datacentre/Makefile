CC = g++
CFLAGS = -std=c++11 -O3 -w -Wall -Wno-deprecated -Wno-unused-variable
#CFLAGS = -std=c++11 -g -w -Wall -Wno-deprecated -Wno-unused-variable
#CRT_space=$(shell pwd) #`pwd`
#CRT=$(strip $(CRT_space))

BASEDIR=/u/az6922/DRing/src/emp
# BASEDIR=/home/annzhou/DRing/src/emp
#BASEDIR=/Users/annzhou/research/uiuc/DRing/src/emp
CRT=$(BASEDIR)/datacentre
# GRB=/home/annzhou/gurobi912/linux64/include
#GRB=/Library/gurobi911/mac64/include
CRT_1UP=$(BASEDIR)
INCLUDE= -I/$(CRT_1UP) -I$(CRT)
# INCLUDE= -I/$(CRT_1UP) -I$(CRT) -I$(GRB)
#-I$(CRT)/ksp -I$(CRT)/ksp/boost
# GRBLIB=/home/annzhou/gurobi912/linux64/lib
#GRBLIB=/Library/gurobi911/mac64/lib
LIB=-L..
# LIB=-L.. -L${GRBLIB}
#-Lksp


all:	eval

eval: main_eval.o ../libhtsim.a leaf_spine_topology.o rand_regular_topology.o connection_matrix_eval.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o
	$(CC) $(INCLUDE) $(CFLAGS)  main_eval.o leaf_spine_topology.o rand_regular_topology.o connection_matrix_eval.o Graph.o YenTopKShortestPathsAlg.o BhandariTopKDisjointPathsAlg.o DijkstraShortestPathAlg.o $(LIB) -lhtsim -o eval


main_eval.o: main_eval.cpp main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c main_eval.cpp 

connection_matrix_eval.o: connection_matrix_eval.cpp main.h 
	$(CC) $(INCLUDE) $(CFLAGS) -c connection_matrix_eval.cpp 

leaf_spine_topology.o: leaf_spine_topology.cpp leaf_spine_topology.h topology.h  main.h
	$(CC) $(INCLUDE) $(CFLAGS) -c leaf_spine_topology.cpp

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
	rm *.o eval
