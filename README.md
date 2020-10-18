# DRing
Packet-level simulation for 2020 HotNets paper "Spineless Data centers".
Adapted from the following papers
- Expanding across time to deliver bandwidth efficiency and low latency, NSDI 2020
  (https://github.com/TritonNetworking/opera-sim)
- Jellyfish: Networking Data Centers Randomly, NSDI 2012

## Requirements:

- C++ files: g++-7 compiler

## Description:

- The /src/emp directory contains the packet simulator source code. The packet simulator is an extension of the htsim NDP simulator (https://github.com/nets-cs-pub-ro/NDP/tree/master/sim)

## Build instructions:

- Build and run the simulator
  ```
  cd /src/emp
  make
  cd /datacenter
  ./cmds_flowsize.sh
