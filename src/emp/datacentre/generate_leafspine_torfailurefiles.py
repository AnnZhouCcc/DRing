# Modified from makelinkfailurefiles.ipynb

# Read in parameters
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--numfailtor", type=int, default=0, help="")
parser.add_argument("--rseed", type=int, default=0, help="")
parser.add_argument("--torfailurefile", type=str, default="", help="")

args = parser.parse_args()

numfailtor = args.numfailtor
rseed = args.rseed
torfailurefile = args.torfailurefile






import random

random.seed(rseed)
torlist = list()
for i in range(numfailtor):
    while True:
        tor = random.randint(0,63)
        if tor not in torlist:
            torlist.append(tor)
            break

# print(torlist)

with open(torfailurefile,'w') as f:
    for tor in torlist:
        f.write(f"{tor}\n")