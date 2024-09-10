1. Generate 1_0_0 traffic file
```
makeflowfiles/makec2s.ipynb
need to use the right leafspine_3072_80_64 in serverfiles (differ in how to number the spine and leaf switches, which ones first)

c = 64
s = 64
numleaf = 64
mult = 1
numerator = 0
denominator = 0
seed = 0
numserver = 3072
numsw = 80
numport = 64
```

2. Calculate mult in `networkbottleneck/networkbottleneck.ipynb`
- load 50%
| c  | s  | load  |
| -- | -- | ----- |
| 64 | 64 | 0.45  |
| 48 | 48 | 0.8   |
| 32 | 32 | 1.8   |
| 16 | 16 | 7.2   |
| 4  | 4  | 115.2 |

3. Generate trafficfiles in `makeflowfiles/makec2s_networkbottleneck.ipynb`

4. Decide on what routing to use
- use equal path weights to test
- mostly su3, also have su2

5. Generate pathweightfiles in `makepathweightfiles/makepathweightfiles_networkbottleneck.ipynb`

6. Generate conffiles, run experiments