This is for scalability with varying number of supernodes

1. Decide on the load -- try 10% for all-rack-to-10%-rack

2. Generate graphfile in `scalability2/parse_analyze_scalegraphfiles2.ipynb` (one time only)

3. Generate flow file with multstr 1_0_0 with `makeflowfiles/makec2s_scalability2.ipynb`
- we do c+s=numsw, thus the sending and receiving switches are all disjoint

4. Calculate mult in `scalability2/scalability2.ipynb`

5. Generate flow file according to the mult with `makeflowfiles/makec2s_scalability2.ipynb`

6. Generate net path file (no need to repeat)
- use su3
- `makenetpathfiles/makesuk_scalability2.py`

7. Generate path weight file according to the flow file with `makepathweightfiles/makepathweightfiles_scalability2.py`

8. Set up conf files, run
```
python3 run_oblivious_c2s.py --conf experiments/scalability/dring.conf --maxGB 15 --waitSec 60
python3 run_oblivious_c2s.py --conf experiments/scalability/rrg.conf --maxGB 15 --waitSec 60
```
