import sys

topology=sys.argv[1]
routing=sys.argv[2]
traffic=sys.argv[3]
isdbr=int(sys.argv[4])
solvermethod="barriernocrossover"
precision=64
numswitches=80

netpathfile = "netpathfiles/netpath_"+routing+"_"+topology+".txt"
if isdbr==0:
    pathweightfile = "pathweightfiles/"+topology+"/"+routing+"/"+traffic+"/pathweight_"+topology+"_"+routing+"_"+traffic+"_lp1_"+solvermethod+"_"+str(precision)+".txt"
else:
    pathweightfile = "pathweightfiles/"+topology+"/"+routing+"/"+traffic+"/pathweight_pbr1_"+topology+"_"+routing+"_"+traffic+"_lp1_"+solvermethod+"_"+str(precision)+".txt"

numrows = numswitches
numcolumns = numswitches
pathlengthlist = [[dict() for y in range(numcolumns)] for x in range(numrows)]

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
        
pathlengthperrackpairlist = [[list() for y in range(numcolumns)] for x in range(numrows)]
numpathsperrackpairlist = [[0 for y in range(numcolumns)] for x in range(numrows)]
numdistinctfirsthopsperrackpairlist = [[set() for y in range(numcolumns)] for x in range(numrows)]
with open(pathweightfile,'r') as pathweightfile:
    for line in pathweightfile:
        tokens = line.split()
        flowfrom = int(tokens[0])
        flowto = int(tokens[1])
        pid = int(tokens[2])
        firsthopfrom = tokens[3]
        firsthopto = tokens[4]
        weight = float(tokens[5])

        pathlengthperrackpairlist[flowfrom][flowto].append(pathlengthlist[flowfrom][flowto][pid]*weight)
        numpathsperrackpairlist[flowfrom][flowto]+=1
        numdistinctfirsthopsperrackpairlist[flowfrom][flowto].add(firsthopfrom+"-"+firsthopto)

pathlengthflatlist = list()
numpathsflatlist = list()
numdistinctfirsthopsflatlist = list()
for srcsw in range(numswitches):
    for dstsw in range(numswitches):
        if numpathsperrackpairlist[srcsw][dstsw]>0:
            pathlengthflatlist.append(sum(pathlengthperrackpairlist[srcsw][dstsw]))
            numpathsflatlist.append(numpathsperrackpairlist[srcsw][dstsw])
            numdistinctfirsthopsflatlist.append(len(numdistinctfirsthopsperrackpairlist[srcsw][dstsw]))
# average path length
print(sum(pathlengthflatlist)/len(pathlengthflatlist))
# average number of paths
print(sum(numpathsflatlist)/len(numpathsflatlist))
# average number of distinct first hops
print(sum(numdistinctfirsthopsflatlist)/len(numdistinctfirsthopsflatlist))
