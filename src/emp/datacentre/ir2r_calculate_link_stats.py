#take inputfile from _parsed_special
#whatever flows that are logged in the file should be counted
#sorting is not working

import sys

filename=sys.argv[1]

numswitches=80
sumfctperlink=dict()
numflowsperlink=dict()
with open(filename,'r') as f:
    for l in f:
        tokens=l.split('\t')
        flowstart=float(tokens[0])
        fct=float(tokens[1])
        flowsize=int(tokens[2])
        for i in range(3,len(tokens)):
            link=tokens[i]
            oldsumfct=0
            oldnumflows=0
            if link in sumfctperlink:
                oldsumfct=sumfctperlink[link]
                oldnumflows=numflowsperlink[link]
            sumfctperlink[link]=oldsumfct+fct
            numflowsperlink[link]=oldnumflows+1

averageperlink=dict()
for link,sumfct in sumfctperlink.items():
    numflows=numflowsperlink[link]
    average=sumfct/numflows
    averageperlink[link]=average

sortedaverageperlink=dict()
currmaxlink=""
currmaxtraffic=-1
while len(sortedaverageperlink) < len(averageperlink):
    for link,traffic in averageperlink.items():
        if traffic > currmaxtraffic:
            currmaxlink=link
            currmaxtraffic=traffic
    sortedaverageperlink[currmaxlink]=currmaxtraffic
    averageperlink[currmaxlink]=-1
    currmaxtraffic=-1

with open(filename+"_links",'w') as f:
    for link,traffic in sortedaverageperlink.items():
        f.write(link+" "+str(traffic)+"\n")
