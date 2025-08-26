# Read in parameters
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--p", type=int, default=2, help="")
parser.add_argument("--a", type=int, default=3, help="")
parser.add_argument("--h", type=int, default=1, help="")
parser.add_argument("--topologyfile", type=str, default="", help="")
parser.add_argument("--serverfile", type=str, default="", help="")

args = parser.parse_args()

p = args.p
a = args.a
h = args.h
topologyfile = args.topologyfile
serverfile = args.serverfile    


nswitches = a*(a*h+1)

with open(serverfile,'w') as fserver:
    # Switch → Host and Host → Switch links
    for j in range(nswitches):
        for l in range(p):
            k = j * p + l
            fserver.write(f"{k},{j}\n")

with open(topologyfile,'w') as ftopo:
    # Switch ↔ Switch links
    for j in range(nswitches):
        groupid = j // a

        # Intra-group full mesh
        for k in range(j + 1, (groupid + 1) * a):
            ftopo.write(f"{k}->{j}\n")

        # Global links (inter-group)
        for l in range(h):
            targetgroupid = (j % a) * h + l
            larger = targetgroupid >= groupid
            if larger:
                targetgroupid += 1
            else:
                continue

            k = targetgroupid * a + groupid // h

            ftopo.write(f"{k}->{j}\n")
