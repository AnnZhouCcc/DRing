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
1. `./discover.sh [topology] [routing] [mode] [lpsolvermode] [searchstart] [searchend] [solveinterval] [computeinterval] [computestart]`
Parameters used:
- clustera (optimal)
```
5 trafficmatrix=clustera
11 stime=200
16 trafficfilename=a
```
Example (optimal at granularity of 3600s): `./discover.sh rrg su3 lpdbr-optimal-3600-3600 barriernocrossover 22.25 22.5 3600 3600 7200`
- clusterb (optimal)
```
5 trafficmatrix=clusterb
11 stime=320
16 trafficfilename=b
```
- clusterc (optimal)
```
5 trafficmatrix=clusterc
11 stime=240
16 trafficfilename=c
```
- a2a
```
5 trafficmatrix=a2a
11 stime=200
16 trafficfilename=null
```
Example: `./discover.sh rrg su3 lppbr barriernocrossover 0.78 0.79 0 0 0` 
- r2r
```
5 trafficmatrix=r2r0/r2r1/r2r2/r2r3/r2r4
11 stime=200
16 trafficfilename=null
```
- 16to4
```
5 trafficmatrix=16to4-0/16to4-1/16to4-2/16to4-3/16to4-4
11 stime=640
16 trafficfilename=null
```

## Experiment 4: (optimal vs delay vs lazy)
An example configurations of how to set optimal vs delay vs lazy:
| solvelen | computelen | computestart |
| ----------- | ----------- | ----------- |
| optimal | 900 | 900 | 7200 |
| delay | 900 | 900 | 6300 |
| optimal | 1800 | 1800 | 7200 |
| delay | 1800 | 900 | 6300 |
| delay | 1800 | 1800 | 5400 |
| optimal | 3600 | 3600 | 7200 |
| delay | 3600 | 900 | 6300 |
| delay | 3600 | 1800 | 5400 |
| delay | 3600 | 3600 | 3600 |
| optimal | 7200 | 7200 | 7200 |
| delay | 7200 | 900 | 6300 |
| delay | 7200 | 1800 | 5400 |
| delay | 7200 | 3600 | 3600 |
| delay | 7200 | 7200 | 0 |

## Experiment 5: calculate path stats
1. `netpathfile` and `pathweightfile` need to be set up.
2. If synthetic traffic, use in `calculate_path_stats_in_bulk.sh`:
```
11 python3 calculate_path_stats_for_synthetic_traffic.py $topology $routing $traffic 0
12 #python3 calculate_path_stats_for_cluster_traffic.py $topology $routing $traffic 0

16 python3 calculate_path_stats_for_synthetic_traffic.py $topology $routing $traffic 1
17 #python3 calculate_path_stats_for_cluster_traffic.py $topology $routing $traffic 1
```
If cluster traffic, use:
```
11 #python3 calculate_path_stats_for_synthetic_traffic.py $topology $routing $traffic 0
12 python3 calculate_path_stats_for_cluster_traffic.py $topology $routing $traffic 0

16 #python3 calculate_path_stats_for_synthetic_traffic.py $topology $routing $traffic 1
17 python3 calculate_path_stats_for_cluster_traffic.py $topology $routing $traffic 1
```
3. Run `./calculate_path_stats_in_bulk.sh [traffic]`
[traffic] can be a2a, r2r0, 16to4-0, clustera, etc.

## Sud
Used to refer to changes made for NSDI'24 fall submission. 

`suddiscover.sh` has more inputs and parameter parsing than the original `discover.sh`. The additions correspond to the new experiments. In `suddiscover.sh`, output directory name `dir` is also different.

## decay
The experiment wants to see whether using weighted historical TMs to compute path weights could help with cluster traffic performance.

How to invoke: 
```
Set L5 traffixmatrix=clusterc
Set L16 trafficfilename=c
./suddiscover.sh rrg 32disjoint lppbr-delay-1800-1800-decay1 barriernocrossover (searchstart) (searchend) 1800 1800 5400 1
```
- the first 1800 refers to `solveinterval`
- the second 1800 refers to `computeinterval`
- `computestart = 5400 = 7200 - 1800`
- can be `decay1` or `decay2`
- for cluster a,b,c, they have different `stime`

Where are pathweightfiles stored:
```
/home/annzhou/DRing/src/emp/datacentre/pathweightfiles/$topology/$routing/$traffic/
```

Notes on decay:
```
1.
$mode=lppbr-delay-1800(solveinterval)-1800(computeinterval)-decay1/2
2.
if $decaymode = 0:
  pwfile as usual
else: // $decaymode = 1 or 2:
  pwfile=.../pathweight_decay1/2_$topology_$routing_$traffic...
  if dbr: pathweight_pbr1_decay1/2_
```

## tera

## kawa

## Repos involved in the Starfish project
| Repo | Description | GitHub | Local data? |
| ----------- | ----------- | ----------- | ----------- |
| DRing | The packet simulator. | this | |
| topobench | Contains most of the objects such as Graph, TrafficMatrix, etc. | [repo](https://github.com/AnnZhouCcc/topobench) | |
| WeightTuning | Set up LP and solve, through reading lp file or Gurobi Java API. | [repo](https://github.com/AnnZhouCcc/WeightTuning) | |
| PathWeightFileGenerator | 1.Quantize; 2.Convert PBR to DBR; 3.Evaluate leafspine. | [repo](https://github.com/AnnZhouCcc/PathWeightFileGenerator) | |
| ObliviousRoutingInvestigation | Generate and parse path weight files for oblivious routing. | [repo](https://github.com/AnnZhouCcc/ObliviousRoutingInvestigation) | |
| MiscellaneousScripts | A collection of miscellaneous scripts, some quite important. | [repo](https://github.com/AnnZhouCcc/MiscellaneousScripts) | |
| WTHelpers | (heavily used before, not used now) A collection of helper methods related to path weight tuning. | [repo](https://github.com/AnnZhouCcc/WTHelpers) | |
| PathWeightFileChecker | (used before, I think not used now) Check the correctness of the path weight files. | [repo](https://github.com/AnnZhouCcc/PathWeightFileChecker) | |
| yates-ann | Generate and transfer path files from SMORE. | [repo](https://github.com/AnnZhouCcc/yates-ann) | Y |
| yates-transfer | Generate and transfer path files from SMORE. | [repo](https://github.com/AnnZhouCcc/yates-transfer) | |
| DataParsing | Parse the cluster traffic from Meta. | [repo](https://github.com/AnnZhouCcc/DataParsing) | Y |
| DataAnalysis | Compute stats of the cluster traffic from Meta. | [repo](https://github.com/AnnZhouCcc/DataAnalysis) | |
| semi\_oblivious\_sigcomm\_plotting | Plotting scripts for figures in the SIGCOMM submission. | [repo](https://github.com/ruipeterpan/semi_oblivious_sigcomm_plotting) | |
| RoutingComparison | (Not used; correctness unsure; could be potentially useful) Compare to WCMP. | [repo](https://github.com/AnnZhouCcc/RoutingComparison) | |
| GRDelay | (Not used; correctness unsure) I think involving cluste delay. | [repo](https://github.com/AnnZhouCcc/GRDelay) | |
| LocalRouting | (Not used; correctness unsure) Investigate making routing decisions purely based on local information of a switch. | [repo](https://github.com/AnnZhouCcc/LocalRouting) | |
| LRConvergence | (Not used; correctness unsure) Investigate making routing decisions purely based on local information of a switch. | [repo](https://github.com/AnnZhouCcc/LRConvergence) | |
| Topology | (Not used; correctness unsure) 1.Compute stats; 2.Generate netpath file. | [repo](https://github.com/AnnZhouCcc/Topology) | |

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
