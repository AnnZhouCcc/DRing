import matplotlib 
matplotlib.use('Agg')
import matplotlib.pyplot as plt

topologyroutingmapping={"rrg":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2","ecmp2"],"dring":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2","su22"],"ls":["ecmp"]}
trafficmatrix="a2a"

topologylinemapping={"rrg":'-',"dring":'--',"ls":':'}
routingcolormapping={"ecmp":'r',"su2":'y',"su3":'g',"32disjoint":'m',"32short":'c',"racke0":'b',"racke1":'slategrey',"racke2":'navy',"ecmp2":'teal',"su22":'salmon'}
modemarkermapping={"equal":'o',"lp":'x',"weighted":'s'}

plt.rcParams["figure.figsize"] = [20,9]
plt.axis([0,12e10,0,6])
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
                trafficpoints=[]
                fctpoints=[]
                for j in range(numpoints):
                    row=rows[i].split("\t")
                    i+=1
                    traffic=int(row[5])
                    n99fct=float(row[3])
                    trafficpoints.append(traffic)
                    fctpoints.append(n99fct)
                plt.plot(trafficpoints,fctpoints,color=routingcolormapping[routing],marker=modemarkermapping[mode],markersize=5,linestyle=topologylinemapping[topology],label=topology+"_"+routing+"_"+mode,alpha=0.7)
            else:
                print("***Error: row[0]!=mode, row[0]="+row[0])
plt.legend(loc="upper center", prop={'size': 8},ncol=3)
plt.savefig("topoflows_flowsize_"+trafficmatrix+".pdf")        
            
