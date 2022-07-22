# Write out a traffic matrix
1. Change:
- L1-10 in `run_storetm.sh`
- L31 in `main_storetm.cpp`
- If running rack-to-rack, additionally change `inst=1` in `connection_matrix.cpp`.
2. Run `./run_storetm.sh > output`
3. Run `rm output` afterwards

# Write out netpath
1. Change:
- L1-6 in `run_storenetpath.sh`
- L32 in `main_storenetpath.cpp`
2. Run `./run_storenetpath.sh > output`
3. Run `rm output` afterwards

# Run experiments with fixed path weights
- Need to run with netpath from file as well
1. Change:
- `PATHWEIGHTS`, `pathWeightFile`, `netPathFile` in `rand_regular_topology.cpp`
- `PATHWEIGHTS` in `main_flowsize.cpp`
2. Run `./netpath_cmds_flowsize.sh` (or equivalent script)

# Compute statistics
1. Change:
- Parameters and function calls in `main_compute.cpp`
- L7 in `run_compute.cpp`
2. Run `./run_compute.cpp > output`
3. Run `rm output` afterwards