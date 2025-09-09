# Modified from makelinkfailurefiles.ipynb

# Read in parameters
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--numfaillinks", type=int, default=0, help="")
parser.add_argument("--rseed", type=int, default=0, help="")
parser.add_argument("--linkfailurefile", type=str, default="", help="")

args = parser.parse_args()

numfaillinks = args.numfaillinks
rseed = args.rseed
linkfailurefile = args.linkfailurefile






NLO = 64 # NL
NUP = 16 # NSP
numtotallinks = NLO*NUP*2


import random

def generate_srcdst():
    mylo = random.randint(0,NLO-1)
    myup = random.randint(0,NUP-1)
    mydirection = random.randint(0,1)
    while mylo==myup:
        myup = random.randint(0,NUP-1)
    return [mylo,myup,mydirection]

def check_repeated_srcdst(lo,up,direction,lolist,uplist,directionlist):
    for i in range(len(lolist)):
        mylo = lolist[i]
        myup = uplist[i]
        mydirection = directionlist[i]
        if lo==mylo and up==myup and direction==mydirection:
            return True
    return False


random.seed(rseed)
lolist = list()
uplist = list()
directionlist = list()
for i in range(numfaillinks):
    mylo,myup,mydirection = generate_srcdst()
    while check_repeated_srcdst(mylo,myup,mydirection,lolist,uplist,directionlist):
        mylo,myup,mydirection = generate_srcdst()
    lolist.append(mylo)
    uplist.append(myup)
    directionlist.append(mydirection)

# print(lolist)
# print(uplist)
# print(directionlist)

with open(linkfailurefile,'w') as f:
    for ilo,lo in enumerate(lolist):
        up = uplist[ilo]
        direction = directionlist[ilo]
        f.write(f"{lo} {up} {direction}\n")