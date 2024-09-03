import sys


trafficfilename = sys.argv[1]
scaledown = int(sys.argv[2])



homedir = "/home/annzhou"
numserver = 2988
numsw = 80
numport = 64
numinterval = 8

# no H yet, just test throughout and see how the spatial pattern changes





# read dring serverfile
serverfile = f"{homedir}/DRing/src/emp/datacentre/serverfiles/dring_{numserver}_{numsw}_{numport}"
serverdict = dict()
with open(serverfile,'r') as f:
    lines = f.readlines()
    for line in lines:
        tokens = line.split(',')
        serverdict[int(tokens[0])] = int(tokens[1])





traffic = list()
for k in range(numinterval):
    traffic.append(list())
    for i in range(numsw):
        traffic[k].append(list())
        for j in range(numsw):
            traffic[k][i].append(0)
trafficfile = f"{homedir}/DRing/src/emp/datacentre/trafficfiles/{trafficfilename}"
with open(trafficfile,'r') as f:
    lines = f.readlines()
    for line in lines:
        tokens = line.split(',')
        interval = int(tokens[0])
        fromsvr = int(tokens[1])
        tosvr = int(tokens[2])
        if fromsvr>=numserver or tosvr>=numserver: continue
        fromsw = serverdict[fromsvr]
        tosw = serverdict[tosvr]
        if fromsw == tosw: continue
        flowbytes = int(tokens[3])
        traffic[interval][fromsw][tosw] += flowbytes
for k in range(numinterval):
    for i in range(numsw):
        for j in range(numsw):
            traffic[k][i][j] /= scaledown






# solve gurobi
# copy from makepathweightfiles/makepathweightfiles.ipynb

# set parameters
graphname = "dring"
numfaillink = 0
numlink = 2132
fseed = 0

# c=64
# s=4
# multstr="2_7_8"
# tseed = 0
# trafficname = f"c2s_{c}_{s}_{tseed}_{multstr}"
trafficname = trafficfilename

method = -1
crossover = 0
factor = 64


# flowfile = f"{homedir}/DRing/src/emp/datacentre/flowfiles/c2s_{c}_{s}_{multstr}_{tseed}"

if graphname=="dring":
    graphfile = f"{homedir}/DRing/src/emp/datacentre/graphfiles/ring_supergraph/double_ring/instance1_{numsw}_{numport}.edgelist"
elif graphname=="rrg":
    graphfile = f"{homedir}/DRing/src/emp/datacentre/graphfiles/ring_supergraph/rrg/instance1_{numsw}_{numport}.edgelist"
else:
    print("ERROR: leafspine does not need to compute path weight")

# tag = f"{graphname}_{numfaillink}_{fseed}_{routingname}_{trafficname}_{method}_{crossover}_{factor}"
tag = f"{graphname}_{trafficname}_{method}_{crossover}_{factor}_d{scaledown}"
# varfile = f"{homedir}/DRing/src/emp/datacentre/qvarfiles/var_{tag}"
# qvarfile = f"{homedir}/DRing/src/emp/datacentre/qvarfiles/qvar_{tag}"
resultfile = f"{homedir}/DRing/src/emp/datacentre/computerouting/output/spatial_{tag}"
modelfile = f"{homedir}/DRing/src/emp/datacentre/makepathweightfiles/model.lp"




for routingname in ["ecmp","su2","su3","32disjoint"]:
    for interval in range(numinterval):

    
        if graphname=="dring" or graphname=="rrg":
            netpathfile = f"{homedir}/DRing/src/emp/datacentre/netpathfiles/netpath_{routingname}_{graphname}.txt"
        else:
            print("ERROR: leafspine does not need to compute path weight")


        # linkfailurefile = f"{homedir}/DRing/src/emp/datacentre/linkfailurefiles/{graphname}_{numlink}_{numfaillink}_{fseed}"

        # serverfile = f"{homedir}/DRing/src/emp/datacentre/serverfiles/{graphname}_{numserver}_{numsw}_{numport}"





        # read netpathfile
        netpath = list()
        for i in range(numsw):
            netpath.append(list())
            for j in range(numsw):
                netpath[i].append(list())
        with open(netpathfile,'r') as f:
            lines = f.readlines()
            # produce
            fromsw = 0
            tosw = 0
            for line in lines:
                if "->" not in line:
                    tokens = line.split()
                    fromsw = int(tokens[0])
                    tosw = int(tokens[1])
                else:
                    path = [fromsw]
                    tokens = line.split()
                    for token in tokens:
                        hops = token.split("->")
                        path.append(int(hops[1]))
                    netpath[fromsw][tosw].append(path)

            # check
            for line in lines:
                if "->" not in line:
                    tokens = line.split()
                    fromsw = int(tokens[0])
                    tosw = int(tokens[1])
                    numpaths = int(tokens[2])
                    if len(netpath[fromsw][tosw])!=numpaths:
                        print(f"ERROR: netpath is wrong, fromsw={fromsw}, tosw={tosw}, numpaths from file={numpaths}, numpaths from array={len(netpath[fromsw][tosw])}")

        # read graphfile
        link = list()
        for i in range(numsw):
            link.append(list())
            for j in range(numsw):
                link[i].append(0)
        with open(graphfile,'r') as f:
            lines = f.readlines()
            for line in lines:
                tokens = line.split("->")
                fromsw = int(tokens[0])
                tosw = int(tokens[1])
                link[fromsw][tosw] = 1
                link[tosw][fromsw] = 1

        # read linkfailurefile (if needed)
        # if numfaillink > 0:
        #     with open(linkfailurefile,'r') as f:
        #         lines = f.readlines()
        #         for line in lines:
        #             tokens = line.split()
        #             fromsw = int(tokens[0])
        #             tosw = int(tokens[1])
        #             if link[fromsw][tosw] != 1:
        #                 print(f"ERROR: should have a link from {fromsw} to {tosw} but not")
        #             else:
        #                 link[fromsw][tosw] /= 2

        # read serverfile
        # serverdict = dict()
        # with open(serverfile,'r') as f:
        #     lines = f.readlines()
        #     for line in lines:
        #         tokens = line.split(',')
        #         serverdict[int(tokens[0])] = int(tokens[1])

        # read flowfile
        # traffic = list()
        # for i in range(numsw):
        #     traffic.append(list())
        #     for j in range(numsw):
        #         traffic[i].append(0)
        # with open(flowfile,'r') as f:
        #     lines = f.readlines()
        #     for line in lines:
        #         tokens = line.split(",")
        #         fromsvr = int(tokens[0])
        #         tosvr = int(tokens[1])
        #         if fromsvr>=numserver or tosvr>=numserver: continue
        #         fromsw = serverdict[fromsvr]
        #         tosw = serverdict[tosvr]
        #         if fromsw == tosw: continue
        #         flowbytes = int(tokens[2])
        #         traffic[fromsw][tosw] += flowbytes




        # precompute
        flowsvialink = list()
        for i in range(numsw):
            flowsvialink.append(list())
            for j in range(numsw):
                flowsvialink[i].append(list())
        for fromsw in range(numsw):
            for tosw in range(numsw):
                if traffic[interval][fromsw][tosw] > 0:
                    for pid,path in enumerate(netpath[fromsw][tosw]):
                        fidpidstr = f"{fromsw},{tosw},{pid}"
                        prevhop = fromsw
                        for hop in path[1:]:
                            flowsvialink[prevhop][hop].append(fidpidstr)
                            prevhop = hop

        # for fromsw in range(numsw):
        #     for tosw in range(numsw):
        #         traffic[interval][fromsw][tosw] /= 100000







        import gurobipy as gp
        from gurobipy import GRB

        # Create a new model
        model = gp.Model("mcf")

        # Add variables
        maxpid = 0
        for fromsw in range(numsw):
            for tosw in range(numsw):
                maxpid = max(maxpid,len(netpath[fromsw][tosw]))
        vararr = list()
        for fromsw in range(numsw):
            vararr.append(list())
            for tosw in range(numsw):
                vararr[fromsw].append(list())
                for pid in range(maxpid):
                    vararr[fromsw][tosw].append(None)
        for fromsw in range(numsw):
            for tosw in range(numsw):
                if traffic[interval][fromsw][tosw] > 0:
                    for pid in range(len(netpath[fromsw][tosw])):
                        var = model.addVar(name=f"{fromsw}_{tosw}_{pid}")
                        vararr[fromsw][tosw][pid] = var
        k = model.addVar(name="k")

        # Set objective function
        model.setObjective(k, GRB.MAXIMIZE)

        # Add constraints
        # Constraint 0: for each fid: sum(pid) >= k * traffic[fid.from][fid.to]
        for fromsw in range(numsw):
            for tosw in range(numsw):
                if traffic[interval][fromsw][tosw] > 0:
                    varlist = list()
                    for pid in range(len(netpath[fromsw][tosw])):
                        varlist.append(vararr[fromsw][tosw][pid])
                    model.addConstr(sum(varlist)>=k*traffic[interval][fromsw][tosw],f"c0_{fromsw}_{tosw}")

        # Constraint 1: for each link: sum(fid_pid) <= link[link.from][link.to]
        for linkfrom in range(numsw):
            for linkto in range(numsw):
                flowstrlist = flowsvialink[linkfrom][linkto]
                if len(flowstrlist) > 0:
                    varlist = list()
                    for flowstr in flowstrlist:
                        tokens = flowstr.split(',')
                        flowfrom = int(tokens[0])
                        flowto = int(tokens[1])
                        pid = int(tokens[2])
                        varlist.append(vararr[flowfrom][flowto][pid])
                    model.addConstr(sum(varlist)<=link[linkfrom][linkto],f"c1_{linkfrom}_{linkto}")

        # Optimize model
        model.setParam('Method',method)
        model.setParam('Crossover',crossover)
        model.optimize()
        # model.write(modelfile)

        # Print results
        if model.status == GRB.OPTIMAL:
            print(f"Optimal objective value: {model.objVal}")
            with open(resultfile,'a') as f:
                f.write(f"{routingname},{interval},{k.x}\n")
                # for fromsw in range(numsw):
                #     for tosw in range(numsw):
                #         if traffic[fromsw][tosw] > 0:
                #             for pid in range(len(netpath[fromsw][tosw])):
                #                 var = vararr[fromsw][tosw][pid]
                #                 f.write(f"{var.varName},{var.x}\n")
        else:
            print("No optimal solution found")