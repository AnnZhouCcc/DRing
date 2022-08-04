from os import listdir
from os.path import isfile,join

topology="rrg"
routing="ecmp"
trafficmatrix="a2a"

dir="fct_results_"+topology+trafficmatrix+routing+"/"
path="DRing/src/emp/datacentre/"+dir
rawmap=dict()
files = [f for f in listdir(path) if isfile(join(path, f))]
for filename in files:
    #rrg_racke1_0_a2a_rrga2aracke1_ii0_5_100_lp_run9_200
    tokens=filename.split('_')
    mult=int(tokens[5][2:])
    numerator=int(tokens[6])
    denominator=int(tokens[7])
    mode=tokens[8]
    run=int(tokens[9][3:])
    value=mult+numerator/denominator

    fctlist=list()
    traffic=0
    numflows=0
    with open(filename,'r') as fd: 
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        for row in rd:
            fctlist.append(int(row[2]))
            traffic+=int(row[1])
            numflows+=1
        
    sort(fctlist)
    n99index=int(numflows*0.99)
    n99fct=fctlist[n99index]

    if mode not in rawmap:
        rawmap[mode]=dict()
    if value not in rawmap[mode]:
        rawmap[mode][value]=dict()
    if run not in rawmap[mode][value]:
        rawmap[mode][value][run]=list()
    rawmap[mode][value][run].append(n99fct)
    rawmap[mode][value][run].append(traffic)

averagemap=dict()
for mode,valuemap in rawmap.items():
    averagemap[mode]=dict()
    for value,runmap in valuemap.items():
        averagemap[mode][value]=list()
        trafficsum=0
        fctsum=0
        numruns=0
        for run,tuplelist in runmap.items():
            fctsum+=tuplelist[0]
            trafficsum+=tuplelist[1]
            numruns+=1
        averagemap[mode][value].append(fctsum/numruns)
        averagemap[mode][value].append(trafficsum/numruns)

writefilename="topoflows_flowsize_"+topology+"_"+trafficmatrix+"_"+routing
with open(writefilename,'w') as fd:
    for mode,valuemap in averagemap.items():
        fd.write("mode\t"+mode+"\t"+len(valuemap)+"\n")
        sort(valuemap)
        for value,tuplelist in valuemap.items():
            fd.write(tuplelist[0]+"\t"+tuplelist[1])