# Modified from makelinkfailurefiles.ipynb

# Read in parameters
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--numfaillinks", type=int, default=0, help="")
parser.add_argument("--rseed", type=int, default=0, help="")
parser.add_argument("--linkfailurefile", type=str, default="", help="")
parser.add_argument("--graphfile", type=str, default="../../../evaltopologyfiles/dring_80_64.edgelist", help="")
parser.add_argument("--numtotalbilinks", type=int, default=1066, help="") # 1066 for dring_80_64

args = parser.parse_args()

numfaillinks = args.numfaillinks
rseed = args.rseed
linkfailurefile = args.linkfailurefile
graphfile = args.graphfile
numtotalbilinks = args.numtotalbilinks


# numtotalbilinks = 1066
# graphfile = "../../../evaltopologyfiles/dring_80_64.edgelist"








import random

def generate_linedirection():
    linenumber = random.randint(0,numtotalbilinks-1)
    direction = random.randint(0,1)
    return [linenumber,direction]

def check_repeated_linedirection(linenumber,direction,linenumberlist,directionlist):
    for i in range(len(linenumberlist)):
        mylinenumber = linenumberlist[i]
        mydirection = directionlist[i]
        if linenumber==mylinenumber and direction==mydirection:
            return True
    return False


linenumberlist = list()
directionlist = list()
for i in range(numfaillinks):
    linenumber,direction = generate_linedirection()
    while check_repeated_linedirection(linenumber,direction,linenumberlist,directionlist):
        linenumber,direction = generate_linedirection()
    linenumberlist.append(linenumber)
    directionlist.append(direction)

# print(linenumberlist)
# print(directionlist)

failsrc = list()
faildst = list()
with open(graphfile,'r') as f:
    lines = f.readlines()
    for ilinenumber,linenumber in enumerate(linenumberlist):
        direction = directionlist[ilinenumber]
        line = lines[linenumber]
        tokens = line.split("->")
        fromsw = int(tokens[0])
        tosw = int(tokens[1])
        if direction==1:
            tempsw = fromsw
            fromsw = tosw
            tosw = tempsw
        failsrc.append(fromsw)
        faildst.append(tosw)
    
# print(failsrc)
# print(faildst)

with open(linkfailurefile,'w') as f:
    for isrc,src in enumerate(failsrc):
        dst = faildst[isrc]
        f.write(f"{src} {dst}\n")