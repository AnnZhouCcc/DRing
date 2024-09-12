Want to test with equal path weights to show 1. worst case for handling controller failure 2. we have a good default routing strategy to fall back to (even for traces that are somewhat random)

1. Test setup
- Traffic: clustera, prv1
- Path weight: equal
- Path selection: try both su2 and su3

2. Generate choicefile and qivarfiles
- choicefiles: all use su3 (2) thoughout
- makepathweightfiles/makeequal.ipynb
- qivarfiles

3. Generate conf files, run experiments
```
python3 run_oblivious_c2s.py --conf experiments/controllerfailure/cluster_a.conf --maxGB 10 --waitSec 60
python3 run_oblivious_c2s.py --conf experiments/controllerfailure/prv1.conf --maxGB 5 --waitSec 60
```
