topologyroutingmapping={"rrg":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2"],"dring":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2"],"ls":["ecmp"]}
trafficmatrix="a2a"
threshold=4.5

for topology,routinglist in topologyroutingmapping.items():
    for routing in routinglist:
        statsfile="/home/annzhou/DRing/src/emp/datacentre/topoflows_flowsize_"+topology+"_"+trafficmatrix+"_"+routing+".txt"
        with open(statsfile,'r') as fd: 
            rows=fd.readlines()
        i=0
        while i < len(rows):
            row=rows[i].split("\t")
            i+=1
            if row[0]=="mode":
                mode=row[1]
                numpoints=int(row[2])
                maxseqno=0
                maxn99fct=0
                for j in range(numpoints):
                    row=rows[i].split("\t")
                    i+=1
                    seqno=float(row[0])
                    n99fct=float(row[3])
		    if seqno > maxseqno:
			maxseqno=seqno
			maxn99fct=n99fct
		if maxn99fct < threshold:
		    print(topology+" "+trafficmatrix+" "+routing+" "+mode+" "+str(maxn99fct)+" "+str(maxseqno))
            else:
                print("***Error: row[0]!=mode, row[0]="+row[0])
            
