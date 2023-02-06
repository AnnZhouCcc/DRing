#take inputfile from _parsed
#whatever flows that are logged in the file should be counted

import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

filename=sys.argv[1]
linkname=sys.argv[2]

mstart=250
mend=750
mmax=1000
numswitches=80
trafficbytime=list()
for i in range(mmax):
    trafficbytime.append(0)
with open(filename,'r') as f:
    for l in f:
        tokens=l.split('\t')
        flowstart=float(tokens[0])-mstart
        fct=float(tokens[1])
        flowsize=int(tokens[2])
        for i in range(3,len(tokens)-1):
            link=tokens[i]
            if link == linkname:
                thisflowstart=int(flowstart)
                thisflowend=min(mmax-1,int(flowstart+fct))
                for index in range(thisflowstart,thisflowend+1):
                    #print(f"{index} {thisflowstart} {thisflowend} {flowstart} {fct}")
                    trafficbytime[index]+=flowsize

x=np.arange(0,mmax,1)
fig, ax = plt.subplots()
ax.plot(x,trafficbytime)
fig.savefig("ir2r_single_link.png")
