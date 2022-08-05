from matplotlib import pyplot as plt

topologylist=["rrg","dring"]
routinglist=["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2"]
trafficmatrix="a2a"

for topology in topologylist:
    for routing in routinglist:
        statsfile="/home/annzhou/DRing/src/emp/datacentre/topoflows_flowsize_"+topology+"_"+trafficmatrix+"_"+routing+".txt"
        rows=[]
        with open(stats,'r') as fd: 
            rd = csv.reader(fd, delimiter="\t", quotechar='"')
            rows.append(rd)
        i=0
        while i < len(rows):
            row=rows[i]
            i+=1
            if row[0]=="mode":
                mode=row[1]
                numpoints=row[2]
                trafficpoints=[]
                fctpoints=[]
                for j in range(numpoints):
                    row=rows[i]
                    i+=1
                    traffic=int(row[0])
                    n99fct=float(row[3])
                    trafficpoints.append(traffic)
                    fctpoints.append(n99fct)
                plt.plot(trafficpoints,fctpoints)
            else:
                print("***Error: row[0]!=mode, row[0]="+row[0])
plt.savefig("topoflows_flowsize_"+trafficmatrix+".pdf")        
            