# Write out a traffic matrix
1. Change:
- L1-9 in `run_storetm.sh`
- L24 in `main_storetm.cpp`
- If running rack-to-rack, additionally change `inst=1` in `connection_matrix.cpp`.
2. Run `./run_storetm.sh > output`
3. Run `rm output` afterwards