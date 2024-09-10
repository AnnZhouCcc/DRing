1. Test setup
- Traffic: clustera, prv1
- Path weight: 3h controller failure, from 1/4 to 2/4

2. Generate choicefile and qivarfiles

3. Generate conf files, run experiments
```
python3 run_oblivious_c2s.py --conf experiments/controllerfailure/cluster_a.conf --maxGB 10 --waitSec 60
python3 run_oblivious_c2s.py --conf experiments/controllerfailure/prv1.conf --maxGB 5 --waitSec 60
```
