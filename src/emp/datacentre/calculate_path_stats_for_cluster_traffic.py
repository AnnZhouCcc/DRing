import sys

topology=sys.argv[1]
routing=sys.argv[2]
traffic=sys.argv[3]
isdbr=int(sys.argv[4])
solvermethod="barriernocrossover"
precision=64
numswitches=80
solvestart=7200
solveend=84600
solveinterval=1800
computestart=5400
computeinterval=1800

netpathfile = "netpathfiles/netpath_"+routing+"_"+topology+".txt"
if isdbr==0:
    pathweightfileprefix = "pathweightfiles/"+topology+"/"+routing+"/"+traffic+"/pathweight_"+topology+"_"+routing+"_"+traffic+"_lp1_"+solvermethod+"_"
else:
    pathweightfileprefix = "pathweightfiles/"+topology+"/"+routing+"/"+traffic+"/pathweight_pbr1_"+topology+"_"+routing+"_"+traffic+"_lp1_"+solvermethod+"_"

numrows = numswitches
numcolumns = numswitches
numintervals = int((solveend-solvestart)/solveinterval)+1
pathlengthlist = [[[dict() for z in range(numintervals)] for y in range(numcolumns)] for x in range(numrows)]

with open(netpathfile,'r') as netpathfile:
    while True:
        line = netpathfile.readline()
        if not line:
            break
        tokens = line.split()
        srcsw = int(tokens[0])
        dstsw = int(tokens[1])
        numpaths = int(tokens[2])
        for pid in range(numpaths):
            line = netpathfile.readline()
            hops = line.split()
            plen = len(hops)
            pathlengthlist[srcsw][dstsw][pid]=plen
        
pathlengthperrackpairlist = [[[list() for z in range(numintervals)] for y in range(numcolumns)] for x in range(numrows)]
numpathsperrackpairlist = [[[0 for z in range(numintervals)] for y in range(numcolumns)] for x in range(numrows)]
numdistinctfirsthopsperrackpairlist = [[[set() for z in range(numintervals)] for y in range(numcolumns)] for x in range(numrows)]
for i in range(numintervals):
    thiscomputestart = computestart + i*solveinterval
    thiscomputeend = thiscomputestart + computeinterval
    pathweightfile = pathweightfileprefix+str(thiscomputestart)+"_"+str(thiscomputeend)+"_"+str(precision)+".txt"
    with open(pathweightfile,'r') as pathweightfile:
        for line in pathweightfile:
            tokens = line.split()
            flowfrom = int(tokens[0])
            flowto = int(tokens[1])
            pid = int(tokens[2])
            firsthopfrom = tokens[3]
            firsthopto = tokens[4]
            weight = float(tokens[5])

            pathlengthperrackpairlist[flowfrom][flowto][i].append(pathlengthlist[flowfrom][flowto][pid]*weight)
            numpathsperrackpairlist[flowfrom][flowto][i]+=1
            numdistinctfirsthopsperrackpairlist[flowfrom][flowto][i].add(firsthopfrom+"-"+firsthopto)

pathlengthflatlist = list()
numpathsflatlist = list()
numdistinctfirsthopsflatlist = list()
for srcsw in range(numswitches):
    for dstsw in range(numswitches):
        for i in range(numintervals):
            if numpathsperrackpairlist[srcsw][dstsw][i]>0:
                pathlengthflatlist.append(sum(pathlengthperrackpairlist[srcsw][dstsw][i]))
                numpathsflatlist.append(numpathsperrackpairlist[srcsw][dstsw][i])
                numdistinctfirsthopsflatlist.append(len(numdistinctfirsthopsperrackpairlist[srcsw][dstsw][i]))
# average path length
print(sum(pathlengthflatlist)/len(pathlengthflatlist))
# average number of paths
print(sum(numpathsflatlist)/len(numpathsflatlist))
# average number of distinct first hops
print(sum(numdistinctfirsthopsflatlist)/len(numdistinctfirsthopsflatlist))
