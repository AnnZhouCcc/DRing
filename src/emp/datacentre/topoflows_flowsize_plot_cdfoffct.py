import matplotlib 
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from os import listdir
from os.path import isfile,join

#topologyroutingmapping={"rrg":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2","ecmp2"],"dring":["ecmp","su2","su3","32disjoint","32short","racke0","racke1","racke2","su22"],"ls":["ecmp"]}
topologyroutingmapping={"rrg":["ecmp"]}
trafficmatrix="a2a"

for topology,routinglist in topologyroutingmapping.items():
    for routing in routinglist:
        path="/home/annzhou/DRing/src/emp/datacentre/fct_results_"+topology+trafficmatrix+routing+"/"
	files = [f for f in listdir(path) if isfile(join(path,f))]
	for filename in files:
	    tokens=filename.split('_')
	    if filename != "rrg_ecmp_0_a2a_rrga2aecmp_ii0_72_100_equal_run0_200":
		continue

            with open(path+filename,'r') as fd: 
                rows=fd.readlines()
            i=0
	    fctlist=list()
            while i < len(rows):
                row=rows[i].split(" ")
            	i+=1
		if row[0]=="topology": continue
		if row[0]!="FCT":
		    print("**Error**: first token is not FCT")
		traffic=int(row[1])
		fct=float(row[2])
		fctlist.append(fct)
	    print(len(fctlist))
	    plt.hist(fctlist,bins=[0,1,2,3,4,5,6,7,8,9],normed=True,cumulative=True,label='rrg-ecmp', histtype='step', alpha=0.55, color='purple')
plt.savefig("topoflows_flowsize_"+topology+trafficmatrix+routing+"_cdf.pdf")            
