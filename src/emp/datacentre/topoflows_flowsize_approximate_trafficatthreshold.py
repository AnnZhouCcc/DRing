topologyroutingmapping={"rrg":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2"],"dring":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2"],"ls":["ecmp"]}
trafficmatrix="a2a"
threshold=4.5
thresholdname="4p5"

writefilename="topoflows_flowsize_"+trafficmatrix+"_"+thresholdname+".txt"
with open(writefilename,'w') as fd:
    for topology,routinglist in topologyroutingmapping.items():
	for routing in routinglist:
	    statsfile="/home/annzhou/DRing/src/emp/datacentre/topoflows_flowsize_"+topology+"_"+trafficmatrix+"_"+routing+".txt"
	    with open(statsfile,'r') as fdr: 
		rows=fdr.readlines()
	    i=0
	    while i < len(rows):
		row=rows[i].split("\t")
		i+=1
		if row[0]=="mode":
		    mode=row[1]
		    numpoints=int(row[2])
		    minabovetraffic=0
		    minaboven99fct=0
		    maxbelowtraffic=0
		    maxbelown99fct=0
		    for j in range(numpoints):
			row=rows[i].split("\t")
			i+=1
			traffic=int(row[5])
			n99fct=float(row[3])
			if n99fct > threshold:
			    if minaboven99fct==0:
				minabovetraffic=traffic
				minaboven99fct=n99fct
			    if n99fct<minaboven99fct:
				minabovetraffic=traffic
				minaboven99fct=n99fct
			elif n99fct<threshold:
			    if n99fct>maxbelown99fct:
				maxbelowtraffic=traffic
				maxbelown99fct=n99fct
		    m = (minaboven99fct-maxbelown99fct)/(minabovetraffic-maxbelowtraffic)
		    b = minaboven99fct-m*minabovetraffic
		    b2=maxbelown99fct-m*maxbelowtraffic
		    if b-b2>0.00000001:
			print("***Error: different b from minabove vs maxbelow, b="+str(b)+", b2="+str(b2))
		    thx = (threshold-b)/m
		    fd.write(topology+"\t"+routing+"\t"+mode+"\t"+str(thx)+"\n")
		else:
		    print("***Error: row[0]!=mode, row[0]="+row[0])
            
