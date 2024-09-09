1. H should not matter

2. Use equal path weight
```
makepathweightfiles/makeequal.ipynb
qivarfiles/qivar_dring_0_0_fhi_64
```
- still need to quantize

3. Load follows what's tested in routing

4. Generate (almost dummy) choicefile and qivarfiles

5. Generate conffiles, run experiments
```

```
- use ecmp_net_path for fhi

- repurpose solvestart and solvend to be startinterval and endinterval
- rand_regular_topology.cpp when populating the three routing_net_paths arrays, main_flowsize.cpp when populating net_paths_choice, hard-coded for dring
- need to produce choicefile beforehand

```
python3 run_oblivious_c2s.py --conf experiments/routing/unv1.conf --maxGB 5 --waitSec 60
10.6->11.3
python3 run_oblivious_c2s.py --conf experiments/routing/unv1.conf --maxGB 3 --waitSec 60

python3 run_oblivious_c2s.py --conf experiments/routing_fhi/cluster_a.conf --maxGB 10 --waitSec 60
python3 run_oblivious_c2s.py --conf experiments/routing_fhi/cluster_b.conf --maxGB 8 --waitSec 60
python3 run_oblivious_c2s.py --conf experiments/routing_fhi/cluster_c.conf --maxGB 6 --waitSec 60
```

6. Generate sumfile, picklefile, plot

7. Delete file