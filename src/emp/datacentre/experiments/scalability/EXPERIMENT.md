1. Decide on the load -- try 30%,50% for all-rack-to-all-rack

2. Calculate mult
- Generate flowfile with mult 1 0 0 with makeflowfiles/makec2s_scalability_alltoall.py
- Calculate mult in scalability.ipynb

3. Generate flow file according to the mult with makeflowfiles/makec2s_scalability_alltoall.ipynb

4. Generate net path file (no need to repeat)
- for DRing: makenetpathfiles/makesuk_scalability_alltoall.py
- for leafspine: makeecmp_leafspine.ipynb

5. Generate path weight file according to the flow file with makepathweightfiles/makepathweightfiles_scalability_alltoall.py

6. Set up conf files, run
```
python3 run_oblivious_c2s.py --conf experiments/scalability/test2.conf --maxGB 10 --waitSec 30
```