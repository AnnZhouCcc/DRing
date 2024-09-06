1. Calculate the best H to use
```
computerouting2/computerouting2.ipynb
```
| trafficname |  H  |
| ----------- | --- |
| unv1        | 3   |
| prv1        | 2   |
| cluster_a   | 5   |
| cluster_b   | 3   |
| cluste_c    | 2   |
- unv1: H=3 or H=4 yield the same average throughput because they make the same routing choice.
- prv1: H=3 is worse than H=2 as when considering more historic TMs, more outdated TMs could confuse our routing decision. But it's not a huge difference actually, at least in throughput calculation.
- we do H=2 for all. But I think H should not affect things that much.

2. Generate pathweightfiles to use
```
computerouting2/computerouting2.ipynb
```
- qvar vs qivar
- need to note the difference between ivar_* and qivar_: 
    - the interval in ivar: this file is computed based on that interval
    - the interval in qivar: this interval should solve using this file
- even if two solveintervals use the same computeinterval, their qivarfiles might be different due to the randomness in quantization

3. Calculate load
```
total bytes in the trafficfile: computerouting2/computerouting2.ipynb
```
| trafficname |  load  | mult+numerator/denominator |
| ----------- | ------ | -------------------------- |
| unv1        | 10%    | 0 + 17 / 100               |
| unv1        | 30%    | 0 + 51 / 100               |
| unv1        | 50%    | 0 + 17 / 20                |
| unv1        | 70%    | 1 + 19 / 100               |
| unv1        | 90%    | 1 + 53 / 100               |
| ----------- | ------ | -------------------------- |

4. Generate choicefiles
```
computerouting2/computerouting2.ipynb
```

5. Generate conffiles, run experiments
```
testing commands:
./run.sh LEAFSPINE MAKE 80 3072 64 leafspine_unv1 NEW_WISC null 0 1 50 4 8 0 0 0 0 ecmp 0 unv1 0 netpathfiles/netpath_ecmp_leafspine.txt qvarfiles/qvar_leafspine_0_0_ecmp_64 64 50 150 200 0 0 > m_leafspine_unv1.log

./run.sh RRG MAKE 80 2988 64 dring_unv1 NEW_WISC graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 0 1 50 4 8 0 0 0 0 null 0 unv1 0 null null 64 50 150 200 0 0 > m_dring_unv1.log
```
- repurpose solvestart and solvend to be startinterval and endinterval
- rand_regular_topology.cpp when populating the three routing_net_paths arrays, main_flowsize.cpp when populating net_paths_choice, hard-coded for dring
- need to produce choicefile beforehand

```
python3 run_oblivious_c2s.py --conf experiments/routing/unv1.conf --maxGB 5 --waitSec 60
10.6->11.3
python3 run_oblivious_c2s.py --conf experiments/routing/unv1.conf --maxGB 3 --waitSec 60
```

6. Generate sumfile, picklefile, plot

7. Delete file