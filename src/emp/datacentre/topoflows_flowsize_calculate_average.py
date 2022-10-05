from os import listdir
from os.path import isfile,join
import csv

expectednumruns=10
topology="ls"
routingset=["ecmp"]
tminfilename="clusterb"
trafficmatrix="cluster"
offset=1

for routing in routingset:
	dir="fct_results_"+topology+tminfilename+routing+"/"
	path="/home/annzhou/DRing/src/emp/datacentre/"+dir
	rawmap=dict()
	files = [f for f in listdir(path) if isfile(join(path, f))]
	for filename in files:
	    #rrg_racke1_0_a2a_rrga2aracke1_ii0_5_100_lp_run9_200
	    #ls_a2a_lsa2aecmp_ii0_3_1000_lp_run0_200
	    print(filename)
	    tokens=filename.split('_')
	    if topology=="ls":
		if tokens[1]!=trafficmatrix: continue
		mult=int(tokens[3+offset][2:])
		numerator=int(tokens[4+offset])
		denominator=int(tokens[5+offset])
		mode=tokens[6+offset]
		run=int(tokens[7+offset][3:])
		if denominator == 0:
		    value = mult
		else:
		    value=mult+(float(numerator))/denominator
	    else:
		if tokens[3]!=trafficmatrix: continue
		mult=int(tokens[5+offset][2:])
		numerator=int(tokens[6+offset])
		denominator=int(tokens[7+offset])
		mode=tokens[8+offset]
		run=int(tokens[9+offset][3:])
		if denominator == 0:
		    value=mult
		else:
		    value=mult+(float(numerator))/denominator

	    fctlist=list()
	    traffic=0
	    numflows=0
	    fctsum=0
	    with open(join(path,filename),'r') as fd: 
		rd = csv.reader(fd, delimiter=" ", quotechar='"')
		for row in rd:
		    if row[0]=="topology": continue
		    fctlist.append(float(row[2]))
		    traffic+=int(row[1])
		    numflows+=1
		    fctsum+=float(row[2])
		
	    fctlist.sort()
	    n99index=int(numflows*0.99)
	    n99fct=fctlist[n99index]
	    maxfct=fctlist[numflows-1]
	    medianindex=int(numflows/2)
	    medianfct=fctlist[medianindex]
	    averagefct=fctsum/numflows

	    if mode not in rawmap:
		rawmap[mode]=dict()
	    if value not in rawmap[mode]:
		rawmap[mode][value]=dict()
	    if run not in rawmap[mode][value]:
		rawmap[mode][value][run]=list()
	    rawmap[mode][value][run].append(averagefct)
	    rawmap[mode][value][run].append(medianfct)
	    rawmap[mode][value][run].append(n99fct)
	    rawmap[mode][value][run].append(maxfct)
	    rawmap[mode][value][run].append(traffic)

	averagemap=dict()
	for mode,valuemap in rawmap.items():
	    averagemap[mode]=dict()
	    for value,runmap in valuemap.items():
		averagemap[mode][value]=list()
		averagefctsum=0
		medianfctsum=0
		n99fctsum=0
		maxfctsum=0
		trafficsum=0
		numruns=0
		for run,tuplelist in runmap.items():
		    averagefctsum+=tuplelist[0]
		    medianfctsum+=tuplelist[1]
		    n99fctsum+=tuplelist[2]
		    maxfctsum+=tuplelist[3]
		    trafficsum+=tuplelist[4]
		    numruns+=1

		if numruns != expectednumruns:
		    print("numruns != expectednumruns")

		averagemap[mode][value].append(averagefctsum/numruns)
		averagemap[mode][value].append(medianfctsum/numruns)
		averagemap[mode][value].append(n99fctsum/numruns)
		averagemap[mode][value].append(maxfctsum/numruns)
		averagemap[mode][value].append(trafficsum/numruns)

	writefilename="topoflows_flowsize_"+topology+"_"+trafficmatrix+"_"+routing+".txt"
	with open(writefilename,'w') as fd:
	    print(writefilename)
	    for mode,valuemap in averagemap.items():
		fd.write("mode\t"+mode+"\t"+str(len(valuemap))+"\n")
		sortedkey=sorted(valuemap.keys())
		for value in sortedkey:
		    tuplelist=valuemap[value]
		    fd.write(str(value)+"\t"+str(tuplelist[0])+"\t"+str(tuplelist[1])+"\t"+str(tuplelist[2])+"\t"+str(tuplelist[3])+"\t"+str(tuplelist[4])+"\n")
