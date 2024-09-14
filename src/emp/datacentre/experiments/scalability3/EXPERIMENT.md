Still scalability set up, but just try 10% for all-rack-to-10%-rack

1. Decide on the load -- try 10% for all-rack-to-10%-rack

2. Generate flowfile with mult 1 0 0 with `makeflowfiles/makec2s_scalability3.ipynb`

3. Calculate mult in `scalability3.ipynb`

4. Generate flow file according to the mult with `makeflowfiles/makec2s_scalability3.ipynb`

5. Generate net path file (no need to repeat)
- use su3
- for DRing: makenetpathfiles/makesuk_scalability_alltoall.py
<!-- - for leafspine: makeecmp_leafspine.ipynb -->
- for RRG: makenetpathfiles/makesuk_scalability_alltoall.py

6. Generate path weight file according to the flow file with `makepathweightfiles/makepathweightfiles_scalability3.py`

7. Set up conf files, run
```
python3 run_oblivious_c2s.py --conf experiments/scalability3/dring.conf --maxGB 10 --waitSec 60
python3 run_oblivious_c2s.py --conf experiments/scalability3/rrg.conf --maxGB 10 --waitSec 60
```