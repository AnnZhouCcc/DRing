LEAFSPINE
y spine switches, 4y racks (leaf switches), 3y svrs/rack
Topologies for y = 8, 12, 16, 20, 24
x: number of svrs/rack, x=3y



RRG
same hardware as leafspine topologies


DRING
12 supernodes (supernode==sn) in the small topologies for number of switches <= 120, switches divided roughly equally among all supernodes.
The number of switches and degree is same as leafspine topologies.
Each DRing topology has 2-3% fewer servers than the corresponding leafspine topology.

leafspine svrs --> dring svrs
768            -->  752
1728           --> 1680
3072           --> 2992
4800           --> 4672
6912           --> 6720

For larger topologies with number of switches > 120, the number of ports for each switch is fixed at 96. For DRing, we increase the number of 
supernodes to obtain a larger topology. The rrgs are equivalent to the DRing in size.

Description of the topologies
switches     servers     supernodes
120           6720          12
140           7840          14
160           8960          16
180           10080         18
200           11200         20

