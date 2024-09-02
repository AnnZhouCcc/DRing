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

- 1. Generate linkfailurefiles
```
in linkfailurefiles/makelinkfailurefiles.ipynb:
DRing: failpercent = 0.02
Leafspine: failpercent = 0.02
```