# Starfish: A Flat Data Center Network

## Experiment 1: (scalability) produce netpathfile for special topology + su3
- `netpath_produce.sh`
1. Fix lines 1,2,3
Example 1:
```
1 topology=dring48
2 graphfile=graphfiles/ring_supergraph/new/instance1_48_60.edgelist
3 numservers=1728
```
Example 2:
```
1 topology=rrg96-2
2 graphfile=graphfiles/ring_supergraph/new/rrg/snodes16/instance2_96_60.edgelist
3 numservers=3456
```
2. Fix lines 10,11,12
```
10 routing=su3
11 routingname=su
12 routingnumber=3
```
3. Use line 46 and comment out line 47
```
46 time ./run.sh $topologyname 1 60 0 $graphfile $numservers 1 1     $make $trafficname $mult $numerator $denominator $solvestart $s    olveend $routingname $routingnumber $trafficparam 0 $seed ${topo    logy}_$suffix $netpathfile $pwfile $precision $mstart $mend $sti    me $solveinterval $computestart $computeend $computeinterval | g    rep -e "FCT" -e "topology" > ${name}/${topology}_${routing}_${mo    de}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
47 #time ./run.sh $topologyname 1 64 16 $graphfile $numservers 1 1     $make $trafficname $mult $numerator $denominator $solvestart $s    olveend $routingname $routingnumber $trafficparam 0 $seed ${topo    logy}_$suffix $netpathfile $pwfile $precision $mstart $mend $sti    me $solveinterval $computestart $computeend $computeinterval | g    rep -e "FCT" -e "topology" > ${name}/${topology}_${routing}_${mo    de}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
```
- `main_flowsize.cpp`
1. Fix line 150 with the name of the netpathfile to be generated
Example: `150 string npfile = "netpath_su3_rrg96-2.txt";`
2. Uncomment lines 425-431
```
425 for (int srcsw=0; srcsw<N; srcsw++) {
426     for (int dstsw=0; dstsw<N; dstsw++) {
427         top->net_paths_rack_based[srcsw][dstsw] = top->get    _paths(srcsw, dstsw).second;
428     }
429 }
430 store_netpath(top->net_paths_rack_based);
431 exit(0);
```
- `rand_regular_topology.cpp`
1. Toggle line 22 PATHWEIGHTS to false (such that we do not need actual netpathfile and pathweightfile)
`22 #define PATHWEIGHTS false`

## Experiment 2: (theoretical optimality) produce netpathfile for rrg/dring + kshort
- `netpath_produce.sh`
1. Fix lines 1,2,3
```
1: topology=rrg
2: graphfile=graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist
3: numservers=3072
```
2. Fix lines 10,11,12
```
10 routing=40short
11 routingname=kshort
12 routingnumber=40
```
3. Use line 47 and comment out line 46
```
46 #time ./run.sh $topologyname 1 60 0 $graphfile $numservers 1 1     $make $trafficname $mult $numerator $denominator $solvestart $s    olveend $routingname $routingnumber $trafficparam 0 $seed ${topo    logy}_$suffix $netpathfile $pwfile $precision $mstart $mend $sti    me $solveinterval $computestart $computeend $computeinterval | g    rep -e "FCT" -e "topology" > ${name}/${topology}_${routing}_${mo    de}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
47 time ./run.sh $topologyname 1 64 16 $graphfile $numservers 1 1     $make $trafficname $mult $numerator $denominator $solvestart $s    olveend $routingname $routingnumber $trafficparam 0 $seed ${topo    logy}_$suffix $netpathfile $pwfile $precision $mstart $mend $sti    me $solveinterval $computestart $computeend $computeinterval | g    rep -e "FCT" -e "topology" > ${name}/${topology}_${routing}_${mo    de}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
```
- `main_flowsize.cpp`
1. Fix line 150 with the name of the netpathfile to be generated
Example: `150 string npfile = "netpath_40short_rrg.txt";`
2. Uncomment lines 425-431
```
425 for (int srcsw=0; srcsw<N; srcsw++) {
426     for (int dstsw=0; dstsw<N; dstsw++) {
427         top->net_paths_rack_based[srcsw][dstsw] = top->get    _paths(srcsw, dstsw).second;
428     }
429 }
430 store_netpath(top->net_paths_rack_based);
431 exit(0);
```
- `rand_regular_topology.cpp`
1. Toggle line 22 PATHWEIGHTS to false (such that we do not need actual netpathfile and pathweightfile)
`22 #define PATHWEIGHTS false`

## Experiment 3: (effective network capacity) 
1. `./discover.sh`
Parameters used:


## Experiment 4:

## Experiment 5:

## Repos involved in the Starfish project
| Repo | Description | Local | GitHub |
| DRing | The packet simulator. | Y | Y |
| Header | Title |
| Paragraph | Text | 

---

# LEGACY Instructions for using the repo
## Write out a traffic matrix
1. Change:
- L1-10 in `run_storetm.sh`
- L31 in `main_storetm.cpp`
- If running rack-to-rack, additionally change `inst=1` in `connection_matrix.cpp`.
2. Run `./run_storetm.sh > output`
3. Run `rm output` afterwards

## Write out netpath
1. Change:
- L1-6 in `run_storenetpath.sh`
- L32 in `main_storenetpath.cpp`
2. Run `./run_storenetpath.sh > output`
3. Run `rm output` afterwards

## Run experiments with fixed path weights
- Need to run with netpath from file as well
1. Change:
- `PATHWEIGHTS`, `pathWeightFile`, `netPathFile` in `rand_regular_topology.cpp`
- `PATHWEIGHTS` in `main_flowsize.cpp`
2. Run `./netpath_cmds_flowsize.sh` (or equivalent script)

## Compute statistics
1. Change:
- Parameters and function calls in `main_compute.cpp`
- L7 in `run_compute.cpp`
2. Run `./run_compute.cpp > output`
3. Run `rm output` afterwards
