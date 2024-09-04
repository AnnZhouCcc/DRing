1. Calculate load i.e. the mult, numerator, denominator that we should use
```
<!-- how to calculate -->
```

| load (%) | value | mult | numerator | denominator |
| -------- | ----- | ---- | --------- | ----------- |
| 10       | 2.875 | 1    | 7         | 16          |
| 30       | 2.875 | 2    | 7         | 8           |
| 50       | 2.875 | 2    | 7         | 8           |
| 70       | 2.875 | 2    | 7         | 8           |
| 90       | 2.875 | 2    | 7         | 8           |

2. Generate 64to4 traffic at different load levels
```
1 traffic seed
in `makeflowfiles/makec2s.ipynb`, set
<!-- c = 64
s = 4
numleaf = 64 -->
mult = 1
numerator = 0
denominator = 0
<!-- seed = 0
numserver = 3072
numsw = 80
numport = 64 -->
```

3. Figure out what routing Starfish would use for 64to4
- 1. Generate pathweightfiles 
```
use 30% load i.e. 4+5/16
makepathweightfiles/makepathweightfiles.ipynb, set
<!-- graphname = "dring" -->
routingname = "ecmp"
<!-- pwname = ""
numsw = 80
numport = 64
numserver = 2988
numfaillink = 0
numlink = 2132
fseed = 0
homedir = "/home/annzhou"

c=64
s=4
multstr="4_5_16"
tseed = 0
trafficname = f"c2s_{c}_{s}_{tseed}_{multstr}"

method = 2
crossover = 0
factor = 64 -->
```

- 2. Set up experiments and run
```
no link failure, 1 traffic seed, 3 simulation seeds
whatrouting.ipynb
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/whatrouting.conf --maxGB 4.2 --waitSec 50
```

- 3. Starfish uses 32disjoint_thisweight for DRing 64to4

- 4. 30% load is too high, need to reduce

4. Find a good range for load -- 20% max
```
test 10%,20% for leafspine + 32disjoint_weight
whatload.ipynb
```
| load (%) | value  | mult | numerator | denominator |
| -------- | ------ | ---- | --------- | ----------- |
| 3        |        | 0    | 69        | 160         |
| 6        | 2.875 | 2    | 7         | 8           |
| 9        | 2.875 | 2    | 7         | 8           |
| 12       | 2.875 | 2    | 7         | 8           |
| 15       | 2.875 | 2    | 7         | 8           |
| 18       | 2.875 | 2    | 7         | 8           |
| 21       | 2.875 | 2    | 7         | 8           |

5. Generate linkfailurefiles
```
in linkfailurefiles/makelinkfailurefiles.ipynb:
DRing: failpercent = 0.02
Leafspine: failpercent = 0.02
```

6. Generate flowfiles

7. Generate pathweightfiles

8. Set up conffiles, untar flowfiles & qvarfiles, run
```
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/0_69_160.conf --maxGB 0.5 --waitSec 20
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/0_69_80.conf --maxGB 1 --waitSec 30
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/1_47_160.conf --maxGB 1.5 --waitSec 40
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/1_29_40.conf --maxGB 2 --waitSec 50
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/2_5_32.conf --maxGB 2.5 --waitSec 60
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/2_47_80.conf --maxGB 3 --waitSec 70
```
```
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/0_69_320.conf --maxGB 0.5 --waitSec 20
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/0_207_320.conf --maxGB 1 --waitSec 30
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/1_5_64.conf --maxGB 1.5 --waitSec 40
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/1_163_320.conf --maxGB 2 --waitSec 50
python3 run_oblivious_c2s.py --conf experiments/linkfailure2/1_301_320.conf --maxGB 2.5 --waitSec 60
```