# Modified from makepathweightfiles/makepathweightfiles.ipynb

# Read in parameters
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--numsw", type=int, default=0, help="")
parser.add_argument("--netpathfile", type=str, default="", help="")
parser.add_argument("--pwfile", type=str, default="", help="")

args = parser.parse_args()

numsw = args.numsw
netpathfile = args.netpathfile
pwfile = args.pwfile




# read netpathfile
netpath = list()
for i in range(numsw):
    netpath.append(list())
    for j in range(numsw):
        netpath[i].append(list())
with open(netpathfile,'r') as f:
    lines = f.readlines()
    # produce
    fromsw = 0
    tosw = 0
    for line in lines:
        if "->" not in line:
            tokens = line.split()
            fromsw = int(tokens[0])
            tosw = int(tokens[1])
        else:
            path = [fromsw]
            tokens = line.split()
            for token in tokens:
                hops = token.split("->")
                path.append(int(hops[1]))
            netpath[fromsw][tosw].append(path)

    # check
    for line in lines:
        if "->" not in line:
            tokens = line.split()
            fromsw = int(tokens[0])
            tosw = int(tokens[1])
            numpaths = int(tokens[2])
            if len(netpath[fromsw][tosw])!=numpaths:
                print(f"ERROR: netpath is wrong, fromsw={fromsw}, tosw={tosw}, numpaths from file={numpaths}, numpaths from array={len(netpath[fromsw][tosw])}")




with open(pwfile,'w') as f:
    for fromsw in range(numsw):
        for tosw in range(numsw):
            if fromsw!=tosw:
                weight = 1/len(netpath[fromsw][tosw])
                for pid,path in enumerate(netpath[fromsw][tosw]):
                    f.write(f"{fromsw},{tosw},{pid},{weight}\n")