1. Generate 1_0_0 traffic file
```
makeflowfiles/makec2s.ipynb
need to use the right leafspine_3072_80_64 in serverfiles (differ in how to number the spine and leaf switches, which ones first)

c = 64
s = 4
numleaf = 64
mult = 1
numerator = 0
denominator = 0
seed = 0
numserver = 3072
numsw = 80
numport = 64
```

2. Calculate mult in `torbottleneck/torbottleneck.ipynb`
- load 10% -> 5%
| c  | s | load |
| -- | - | ---- |
| 64 | 4 | 1.44 |
| 48 | 4 | 1.92 |
| 32 | 4 | 2.88 |
| 16 | 4 | 5.76 |
| 4  | 4 | 23   |
- load 5%
| c  | s | load |
| -- | - | ---- |
| 64 | 4 | 0.72 |
| 48 | 4 | 0.96 |
| 32 | 4 | 1.44 |
| 16 | 4 | 2.88 |
| 4  | 4 | 11.5 |

3. Generate trafficfiles in `makeflowfiles/makec2s_torbottleneck.ipynb`

4. Decide on what routing to use
- use equal path weights to test
- mostly su3, also have su2

5. Generate pathweightfiles in `makepathweightfiles/makepathweightfiles_torbottleneck.ipynb`

6. Generate conffiles, run experiments