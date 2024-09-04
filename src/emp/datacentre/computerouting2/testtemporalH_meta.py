import sys
import os
import gurobipy as gp
from gurobipy import GRB

trafficname = sys.argv[1]
scaledown = int(sys.argv[2])
H = int(sys.argv[3])
homedir = "/home/annzhou"


def compute(interval,graphfile,numsw,netpathfile,traffic,method,crossover,qivarfile):
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

    # Constraint 2: for each fid: for each pid: pid = prev_pid
    # for fromsw in range(numsw):
    #     for tosw in range(numsw):
    #         if traffic[interval][fromsw][tosw] > 0:
    #             for pid in range(1,len(netpath[fromsw][tosw])):
    #                 model.addConstr(vararr[fromsw][tosw][pid]-vararr[fromsw][tosw][pid-1]==0,f"c2_{fromsw}_{tosw}_{pid}")

    # Optimize model
    model.setParam('Method',method)
    model.setParam('Crossover',crossover)
    model.optimize()
    # model.write(modelfile)

    # Print results
    if model.status == GRB.OPTIMAL:
        print(f"Optimal objective value: {model.objVal}")
        with open(qivarfile,'a') as f:
            f.write(f"{routingname},{interval},{k.x}\n")
            for fromsw in range(numsw):
                for tosw in range(numsw):
                    if traffic[interval][fromsw][tosw] > 0:
                        for pid in range(len(netpath[fromsw][tosw])):
                            var = vararr[fromsw][tosw][pid]
                            f.write(f"{var.varName},{var.x}\n")
    else:
        print("No optimal solution found")
    return


def solve(computeinterval,computeqivarfile,solveinterval,graphfile,numsw,netpathfile,traffic,cachefile,method,crossover):
    if os.path.exists(cachefile):
        with open(cachefile,'r') as f:
            lines = f.readlines()
            for line in lines:
                tokens = line.split(',')
                mycomputeinterval = int(tokens[0])
                mysolveinterval = int(tokens[1])
                mythroughput = float(tokens[2])
                if computeinterval==mycomputeinterval and solveinterval==mysolveinterval:
                    return mythroughput

    if not os.path.exists(computeqivarfile):
        compute(computeinterval,graphfile,numsw,netpathfile,traffic,method,crossover,computeqivarfile)


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

    # read computeqivarfile
    pathweight = list()
    for i in range(numsw):
        pathweight.append(list())
        for j in range(numsw):
            pathweight[i].append(dict())
    with open(computeqivarfile,'r') as f:
        lines = f.readlines()[1:]
        for line in lines:
            tokens = line.split(",")
            string = tokens[0]
            stringtokens = string.split("_")
            fromsw = int(stringtokens[0])
            tosw = int(stringtokens[1])
            pid = int(stringtokens[2])
            weight = float(tokens[1])
            pathweight[fromsw][tosw][pid] = weight
    for fromsw in range(numsw):
        for tosw in range(numsw):
            if traffic[solveinterval][fromsw][tosw]>0 and traffic[computeinterval][fromsw][tosw]==0:
                numnetpath = len(netpath[fromsw][tosw])
                for i in range(numnetpath):
                    pathweight[fromsw][tosw][i] = 1.0/numnetpath


    # precompute
    flowsvialink = list()
    for i in range(numsw):
        flowsvialink.append(list())
        for j in range(numsw):
            flowsvialink[i].append(list())
    for fromsw in range(numsw):
        for tosw in range(numsw):
            if traffic[solveinterval][fromsw][tosw] > 0:
                for pid,path in enumerate(netpath[fromsw][tosw]):
                    fidpidstr = f"{fromsw},{tosw},{pid}"
                    prevhop = fromsw
                    for hop in path[1:]:
                        flowsvialink[prevhop][hop].append(fidpidstr)
                        prevhop = hop

    # for fromsw in range(numsw):
    #     for tosw in range(numsw):
    #         traffic[interval][fromsw][tosw] /= 100000


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
            if traffic[solveinterval][fromsw][tosw] > 0:
                for pid in range(len(netpath[fromsw][tosw])):
                    var = model.addVar(name=f"{fromsw}_{tosw}_{pid}")
                    vararr[fromsw][tosw][pid] = var
    k = model.addVar(name="k")
    avararr = list()
    for fromsw in range(numsw):
        avararr.append(list())
        for tosw in range(numsw):
            avararr[fromsw].append(None)
    for fromsw in range(numsw):
        for tosw in range(numsw):
            if traffic[solveinterval][fromsw][tosw] > 0:
                avar = model.addVar(name=f"a_{fromsw}_{tosw}")
                avararr[fromsw][tosw] = avar

    # Set objective function
    model.setObjective(k, GRB.MAXIMIZE)

    # Add constraints
    # Constraint 0: for each fid: sum(pid) >= k * traffic[fid.from][fid.to]
    for fromsw in range(numsw):
        for tosw in range(numsw):
            if traffic[solveinterval][fromsw][tosw] > 0:
                varlist = list()
                for pid in range(len(netpath[fromsw][tosw])):
                    varlist.append(vararr[fromsw][tosw][pid])
                model.addConstr(sum(varlist)>=k*traffic[solveinterval][fromsw][tosw],f"c0_{fromsw}_{tosw}")

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

    # Constraint 2: for each fid: for each pid: pid = pathweight[fid][pid] * a[fid]
    for fromsw in range(numsw):
        for tosw in range(numsw):
            if traffic[solveinterval][fromsw][tosw] > 0:
                for pid in range(len(netpath[fromsw][tosw])):
                    model.addConstr(vararr[fromsw][tosw][pid]==pathweight[fromsw][tosw][pid]*avararr[fromsw][tosw],f"c2_{fromsw}_{tosw}_{pid}")

    # Optimize model
    model.setParam('Method',-1)
    model.setParam('Crossover',0)
    model.optimize()
    # model.write(modelfile)

    # Print results
    if model.status == GRB.OPTIMAL:
        print(f"Optimal objective value: {model.objVal}")
        with open(cachefile,'a') as f:
            f.write(f"{computeinterval},{solveinterval},{k.x}\n")
            # for fromsw in range(numsw):
            #     for tosw in range(numsw):
            #         if traffic[fromsw][tosw] > 0:
            #             for pid in range(len(netpath[fromsw][tosw])):
            #                 var = vararr[fromsw][tosw][pid]
            #                 f.write(f"{var.varName},{var.x}\n")
    else:
        print("No optimal solution found")
    return k.x


def find_max_indices(numbers, tolerance):
    # Find the maximum value in the list
    max_value = max(numbers)
    
    # Find all indices where the value is within the tolerance of the maximum value
    indices = [i for i, value in enumerate(numbers) if abs(value - max_value)/max_value <= tolerance]
    
    return indices


def write_arr(file,arr,prefix,suffix):
    file.write(prefix)
    for a in arr:
        file.write(f"{a},")
    file.write(suffix)


# set up parameters
if trafficname == "cluster_b":
    trafficfilesuffixlist = ["0_500","500_1000","1000_1500","1500_2000","2000_2500","2500_2900"]
else:
    trafficfilesuffixlist = ["0_273"]
step_s = 1800
numserver = 2988
numsw = 80
numport = 64
numinterval = 86400//step_s
graphname = "dring"
numfaillink = 0
numlink = 2132
fseed = 0
method = 2
crossover = 0
factor = 64
error_tolerance = 0.01
routingnamearr = ["ecmp","su2","su3","32disjoint"]

if graphname=="dring":
    graphfile = f"{homedir}/DRing/src/emp/datacentre/graphfiles/ring_supergraph/double_ring/instance1_{numsw}_{numport}.edgelist"
elif graphname=="rrg":
    graphfile = f"{homedir}/DRing/src/emp/datacentre/graphfiles/ring_supergraph/rrg/instance1_{numsw}_{numport}.edgelist"
else:
    print("ERROR: leafspine does not need to compute path weight")

spatialfile = f"{homedir}/DRing/src/emp/datacentre/computerouting2/output/spatial_{graphname}_{trafficname}_-1_0_{factor}_d{scaledown}"
modelfile = f"{homedir}/DRing/src/emp/datacentre/makepathweightfiles/model.lp"
resultfile = f"{homedir}/DRing/src/emp/datacentre/computerouting2/resultfiles/result_{graphname}_{numfaillink}_{fseed}_{trafficname}_{method}_{crossover}"
processfile = f"{homedir}/DRing/src/emp/datacentre/computerouting2/processfiles/process_{graphname}_{numfaillink}_{fseed}_{trafficname}_{method}_{crossover}"


# read in traffic
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
for suffix in trafficfilesuffixlist:
    trafficfile = f"{homedir}/DRing/src/emp/datacentre/trafficfiles/{trafficname}/traffic_64racks_{suffix}"
    with open(trafficfile,'r') as f:
        lines = f.readlines()
        for line in lines:
            tokens = line.split()
            time_s = int(tokens[0])
            interval = time_s//step_s
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

totaltraffic_per_interval = list()
for k in range(numinterval):
    totaltraffic = 0
    for i in range(numsw):
        for j in range(numsw):
            totaltraffic += traffic[k][i][j]
    totaltraffic_per_interval.append(totaltraffic)


# read in throughput with equal path weights
equalthroughput = dict()
for routingname in routingnamearr:
    equalthroughput[routingname] = dict()
with open(spatialfile,'r') as f:
    lines = f.readlines()
    for line in lines:
        tokens = line.split(',')
        routingname = tokens[0]
        interval = int(tokens[1])
        throughput = float(tokens[2])
        equalthroughput[routingname][interval] = throughput


# compute & solve
with open(processfile,'a') as fprocess:
    for solveinterval in range(numinterval//2,numinterval):

        spatial_sumthpt = [0]*len(routingnamearr)
        for computeinterval in range(solveinterval-H,solveinterval): # thus exclusing solveinterval itself
            for iroutingname,routingname in enumerate(routingnamearr):
                mythroughput = equalthroughput[routingname][computeinterval] 
                spatial_sumthpt[iroutingname] += mythroughput* totaltraffic_per_interval[computeinterval]
                fprocess.write(f"{H},{solveinterval},spatial,throughput,{computeinterval},{routingname},{mythroughput},{mythroughput* totaltraffic_per_interval[computeinterval]}\n")
        spatial_votes = find_max_indices(spatial_sumthpt,error_tolerance)    
        write_arr(fprocess,spatial_sumthpt,f"{H},{solveinterval},spatial,sumthroughput,","\n")
        write_arr(fprocess,spatial_votes,f"{H},{solveinterval},spatial,vote,","\n")

        temporal_sumthpt = [0] * H*len(spatial_votes)
        for ispatial_vote,spatial_vote in enumerate(spatial_votes):
            for icomputeinterval,computeinterval in enumerate(range(solveinterval-H,solveinterval)):
                for otherinterval in range(solveinterval-H,solveinterval):
                    computeqivarfile = f"{homedir}/DRing/src/emp/datacentre/qivarfiles/ivar_{graphname}_{numfaillink}_{fseed}_{routingnamearr[spatial_vote]}_{trafficname}_{computeinterval}_{method}_{crossover}"
                    cachefile = f"{homedir}/DRing/src/emp/datacentre/computerouting2/cachefiles/cache_{graphname}_{numfaillink}_{fseed}_{routingnamearr[spatial_vote]}_{trafficname}_{method}_{crossover}"
                    netpathfile = f"{homedir}/DRing/src/emp/datacentre/netpathfiles/netpath_{routingnamearr[spatial_vote]}_{graphname}.txt"
                    mythroughput = solve(computeinterval,computeqivarfile,otherinterval,graphfile,numsw,netpathfile,traffic,cachefile,method,crossover)
                    temporal_sumthpt[icomputeinterval+ispatial_vote*H] += mythroughput * totaltraffic_per_interval[otherinterval]
                    fprocess.write(f"{H},{solveinterval},temporal,throughput,{computeinterval},{otherinterval},{routingnamearr[spatial_vote]},{mythroughput},{mythroughput * totaltraffic_per_interval[otherinterval]}\n")
        temporal_votes = find_max_indices(temporal_sumthpt+spatial_sumthpt,error_tolerance)
        write_arr(fprocess,temporal_sumthpt,f"{H},{solveinterval},temporal,sumthroughput,","\n")
        write_arr(fprocess,temporal_votes,f"{H},{solveinterval},temporal,vote,","\n")

        maxpathsused = 0
        final_computeinterval = 0
        final_pathselection = 0
        for temporal_vote in temporal_votes: # AnnC: not rigorous here
            if temporal_vote>=H*len(spatial_votes):
                path_selection = temporal_vote-H*len(spatial_votes)
                base_interval = -1
                pathsused = 1 # AnnC: do not favor equal
                fprocess.write(f"{H},{solveinterval},compare,spatial,{routingnamearr[path_selection]},{base_interval},{pathsused}\n")
            else:
                path_selection = spatial_votes[temporal_vote//H]
                base_interval = range(solveinterval-H,solveinterval)[temporal_vote%H]
                qivarfile = f"{homedir}/DRing/src/emp/datacentre/qivarfiles/ivar_{graphname}_{numfaillink}_{fseed}_{routingnamearr[path_selection]}_{trafficname}_{base_interval}_{method}_{crossover}"
                with open(qivarfile,'r') as f:
                    lines = f.readlines()[1:]
                    pathsused = len(lines)
                    fprocess.write(f"{H},{solveinterval},compare,temporal,{routingnamearr[path_selection]},{base_interval},{pathsused}\n")
            if pathsused > maxpathsused:
                maxpathsused = pathsused
                final_computeinterval = base_interval
                final_pathselection = path_selection

        # write out results
        with open(resultfile,'a') as f:
            if final_computeinterval == -1:
                mythroughput = equalthroughput[routingnamearr[final_pathselection]][solveinterval]
            else:    
                computeqivarfile = f"{homedir}/DRing/src/emp/datacentre/qivarfiles/ivar_{graphname}_{numfaillink}_{fseed}_{routingnamearr[final_pathselection]}_{trafficname}_{final_computeinterval}_{method}_{crossover}"
                cachefile = f"{homedir}/DRing/src/emp/datacentre/computerouting2/cachefiles/cache_{graphname}_{numfaillink}_{fseed}_{routingnamearr[final_pathselection]}_{trafficname}_{method}_{crossover}"
                netpathfile = f"{homedir}/DRing/src/emp/datacentre/netpathfiles/netpath_{routingnamearr[final_pathselection]}_{graphname}.txt"
                mythroughput = solve(final_computeinterval,computeqivarfile,solveinterval,graphfile,numsw,netpathfile,traffic,cachefile,method,crossover)
            f.write(f"{H},{solveinterval},{mythroughput},{routingnamearr[final_pathselection]},{final_computeinterval}\n")
        fprocess.write(f"{H},{solveinterval},final,{routingnamearr[final_pathselection]},{final_computeinterval},{mythroughput}\n")