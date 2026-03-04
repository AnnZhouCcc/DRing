# Modified from makelinkfailurefiles.ipynb

# Read in parameters
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--numsw", type=int, default=0, help="")
parser.add_argument("--torfailurefile", type=str, default="", help="")
parser.add_argument("--netpathfile", type=str, default="", help="")
parser.add_argument("--beforepathweightfile", type=str, default="", help="")
parser.add_argument("--afterpathweightfile", type=str, default="", help="")

args = parser.parse_args()

numsw = args.numsw
torfailurefile = args.torfailurefile
netpathfile = args.netpathfile
beforepathweightfile = args.beforepathweightfile
afterpathweightfile = args.afterpathweightfile






# read netpathfile
# Read all non-empty lines
with open(netpathfile, "r") as f:
    lines = [line.strip() for line in f if line.strip()]

# Find maximum node id first, so we can size the 2D array
max_node = -1
i = 0
while i < len(lines):
    parts = lines[i].split()
    src = int(parts[0])
    dst = int(parts[1])
    npaths = int(parts[2])

    if src > max_node:
        max_node = src
    if dst > max_node:
        max_node = dst

    j = 1
    while j <= npaths:
        path_parts = lines[i + j].split()
        for edge in path_parts:
            a, b = edge.split("->")
            a = int(a)
            b = int(b)
            if a > max_node:
                max_node = a
            if b > max_node:
                max_node = b
        j += 1

    i += npaths + 1

# 2D array: netpathdict[src][dst] = list of paths
netpathdict = [[[] for _ in range(max_node + 1)] for _ in range(max_node + 1)]

# Parse file contents into netpathdict
i = 0
while i < len(lines):
    parts = lines[i].split()
    src = int(parts[0])
    dst = int(parts[1])
    npaths = int(parts[2])

    paths = []
    j = 1
    while j <= npaths:
        path_parts = lines[i + j].split()

        path_nodes = []
        for k, edge in enumerate(path_parts):
            a, b = edge.split("->")
            a = int(a)
            b = int(b)

            if k == 0:
                path_nodes.append(a)
            path_nodes.append(b)

        paths.append(path_nodes)
        j += 1

    netpathdict[src][dst] = paths
    i += npaths + 1



# read torfailurefile
torlist = list()
with open(torfailurefile,'r') as f:
    lines = f.readlines()
    for line in lines:
        torlist.append(int(line.strip()))



# read beforepathweightfile + write afterpathweightfile
pathweightdict = dict()
frbefore = open(beforepathweightfile, 'r')
lines = frbefore.readlines()
for line in lines:
    tokens = line.split(",")
    fromsw = int(tokens[0])
    tosw = int(tokens[1])
    pid = int(tokens[2])
    weight = float(tokens[3])

    path = netpathdict[fromsw][tosw][pid]
    shouldwrite = True
    for hop in path:
        if hop in torlist:
            shouldwrite = False
            break
    if shouldwrite:
        if (fromsw, tosw) not in pathweightdict:
            pathweightdict[(fromsw, tosw)] = list()
        pathweightdict[(fromsw, tosw)].append((pid, weight))
frbefore.close()

fwafter = open(afterpathweightfile, 'w')
for fromsw in range(numsw):
    for tosw in range(numsw):
        if fromsw==tosw or fromsw in torlist or tosw in torlist:
            continue
        # if (fromsw, tosw) not in pathweightdict:
        #     print(f"Warning: no pathweight for {fromsw}->{tosw}")
        #     exit(1)
        if (fromsw, tosw) not in pathweightdict or len(pathweightdict[(fromsw, tosw)]) == 0:
            continue
        totalweight = 0
        for pid, weight in pathweightdict[(fromsw, tosw)]:
            totalweight += weight
        factor = totalweight/1.0
        for pid, weight in pathweightdict[(fromsw, tosw)]:
            newweight = weight/factor
            fwafter.write(f"{fromsw},{tosw},{pid},{newweight}\n")
fwafter.close()
