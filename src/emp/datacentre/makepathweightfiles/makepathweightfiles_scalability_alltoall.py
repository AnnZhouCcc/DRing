graphname = "dring"
routingname = "su2"
numfaillink = 0
fseed = 0
homedir = "/home/annzhou"
tseed = 0
method = 2
crossover = 0
factor = 64


swlist = range(40,121,20)
svrlist = [752,1680,2992,4672,6720]
nlinklist = [264,600,1064,1664,2400]
multstrlist = ["1_74_100","0_78_100","0_44_100","0_28_100","0_19_100"]

for inumsw,numsw in enumerate(swlist):
    numport = int(numsw*0.8)
    numserver = svrlist[inumsw]
    numlink = nlinklist[inumsw]
    multstr=multstrlist[inumsw]
    c=int(numsw*0.8)
    s=int(numsw*0.8)
    trafficname = f"c2s_{c}_{s}_{tseed}_{multstr}"




    flowfile = f"{homedir}/DRing/src/emp/datacentre/flowfiles/c2s_{(numsw//5)*(numsw//5)*12}_{numsw}_{int(numsw*0.8)}_{c}_{s}_{multstr}_{tseed}"

    if graphname=="dring" or graphname=="rrg":
        netpathfile = f"{homedir}/DRing/src/emp/datacentre/netpathfiles/netpath_{routingname}_{graphname}_{numserver}_{numsw}_{int(numsw*0.8)}"
    else:
        print("ERROR: leafspine does not need to compute path weight")

    if graphname=="dring" or graphname=="rrg":
        graphfile = f"{homedir}/DRing/src/emp/datacentre/scalegraphfiles/{graphname}_deg{int(numsw*0.8)}_sw{numsw}_sn12_i1.edgelist"
    else:
        print("ERROR: leafspine does not need to compute path weight")

    linkfailurefile = f"{homedir}/DRing/src/emp/datacentre/linkfailurefiles/{graphname}_{numlink}_{numfaillink}_{fseed}"

    serverfile = f"{homedir}/DRing/src/emp/datacentre/serverfiles/{graphname}_{numserver}_{numsw}_{numport}"

    tag = f"{graphname}_{numserver}_{numsw}_{numport}_{numfaillink}_{fseed}_{routingname}_{trafficname}_{method}_{crossover}_{factor}"
    varfile = f"{homedir}/DRing/src/emp/datacentre/qvarfiles/var_{tag}"
    qvarfile = f"{homedir}/DRing/src/emp/datacentre/qvarfiles/qvar_{tag}"
    # modelfile = f"{homedir}/DRing/src/emp/datacentre/makepathweightfiles/model.lp"








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
    if numfaillink > 0:
        with open(linkfailurefile,'r') as f:
            lines = f.readlines()
            for line in lines:
                tokens = line.split()
                fromsw = int(tokens[0])
                tosw = int(tokens[1])
                if link[fromsw][tosw] != 1:
                    print(f"ERROR: should have a link from {fromsw} to {tosw} but not")
                else:
                    link[fromsw][tosw] /= 2

    # read serverfile
    serverdict = dict()
    with open(serverfile,'r') as f:
        lines = f.readlines()
        for line in lines:
            tokens = line.split(',')
            serverdict[int(tokens[0])] = int(tokens[1])

    # read flowfile
    traffic = list()
    for i in range(numsw):
        traffic.append(list())
        for j in range(numsw):
            traffic[i].append(0)
    with open(flowfile,'r') as f:
        lines = f.readlines()
        for line in lines:
            tokens = line.split(",")
            fromsvr = int(tokens[0])
            tosvr = int(tokens[1])
            if fromsvr>=numserver or tosvr>=numserver: continue
            fromsw = serverdict[fromsvr]
            tosw = serverdict[tosvr]
            if fromsw == tosw: continue
            flowbytes = int(tokens[2])
            traffic[fromsw][tosw] += flowbytes










    # precompute
    flowsvialink = list()
    for i in range(numsw):
        flowsvialink.append(list())
        for j in range(numsw):
            flowsvialink[i].append(list())
    for fromsw in range(numsw):
        for tosw in range(numsw):
            if traffic[fromsw][tosw] > 0:
                for pid,path in enumerate(netpath[fromsw][tosw]):
                    fidpidstr = f"{fromsw},{tosw},{pid}"
                    prevhop = fromsw
                    for hop in path[1:]:
                        flowsvialink[prevhop][hop].append(fidpidstr)
                        prevhop = hop

    for fromsw in range(numsw):
        for tosw in range(numsw):
            traffic[fromsw][tosw] /= 100000










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
            if traffic[fromsw][tosw] > 0:
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
            if traffic[fromsw][tosw] > 0:
                varlist = list()
                for pid in range(len(netpath[fromsw][tosw])):
                    varlist.append(vararr[fromsw][tosw][pid])
                model.addConstr(sum(varlist)>=k*traffic[fromsw][tosw],f"c0_{fromsw}_{tosw}")

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
        with open(varfile,'w') as f:
            f.write(f"{k.varName},{k.x}\n")
            for fromsw in range(numsw):
                for tosw in range(numsw):
                    if traffic[fromsw][tosw] > 0:
                        for pid in range(len(netpath[fromsw][tosw])):
                            var = vararr[fromsw][tosw][pid]
                            f.write(f"{var.varName},{var.x}\n")
    else:
        print("No optimal solution found")










    import random
    random.seed(0)

    def quantize_to_multiple_of_1_64(x,factor):
        return round(x * factor) / factor

    def quantize_and_adjust_with_indices(indexed_values,factor,isprint=False):
        if isprint: print(indexed_values)
        # Quantize each value
        quantized_values = [(i, quantize_to_multiple_of_1_64(v,factor)) for i, v in indexed_values]
        if isprint: print(quantized_values)
        
        # Calculate the current sum
        current_sum = sum(v for _, v in quantized_values)
        
        # Calculate the difference between the sum and 1
        difference = current_sum - 1
        if isprint: print(f"currsum={current_sum}, difference={difference}")

        random_values = [(v, random.random()) for v in quantized_values]
        if isprint: print(random_values)
        
        if difference != 0:
            if difference > 0:
                # Sort indices by quantized values to adjust the largest values first
                sorted_random = sorted(random_values, key=lambda x: (x[0][1],x[1]), reverse=True)
                # sorted_quantized = sorted(quantized_values, key=lambda x: x[1], reverse=True)
                sorted_quantized = [v for v,_ in sorted_random]
                if isprint: print(sorted_random)
                if isprint: print(sorted_quantized)
                
                while difference !=0:
                    for i, value in sorted_quantized:
                        if difference == 0:
                            break
                        # Calculate adjustment
                        # adjustment = min(difference, value % (1 / factor))
                        # adjustment = difference
                        new_value = value - 1.0/factor
                        
                        # Update the quantized values
                        quantized_values = [(idx, new_value if idx == i else v) for idx, v in quantized_values]
                        difference -= 1.0/factor
                    
            else:
                # If the difference is negative (i.e., sum is less than 1), we need to increase values
                # sorted_quantized = sorted(quantized_values, key=lambda x: x[1])
                sorted_random = sorted(random_values, key=lambda x: (x[0][1],x[1]))
                # sorted_quantized = sorted(quantized_values, key=lambda x: x[1], reverse=True)
                sorted_quantized = [v for v,_ in sorted_random]
                
                while difference != 0:
                    for i, value in sorted_quantized:
                        if difference == 0:
                            break
                        # Calculate adjustment
                        # adjustment = min(-difference, (1 / factor) - (value % (1 / factor)))
                        # adjustment = -difference
                        new_value = value + 1.0/factor
                        
                        # Update the quantized values
                        quantized_values = [(idx, new_value if idx == i else v) for idx, v in quantized_values]
                        difference += 1.0/factor
        
        # Return the list sorted by original indices
        # return [v for i, v in sorted(quantized_values)]
        if isprint: print(quantized_values)
        return quantized_values


    with open(varfile,'r') as f:
        lines = f.readlines()[1:]

    valuearr = list()
    weightarr = list()
    qweightarr = list()
    for i in range(numsw):
        valuearr.append(list())
        weightarr.append(list())
        qweightarr.append(list())
        for j in range(numsw):
            valuearr[i].append(list())
            weightarr[i].append(list())
            qweightarr[i].append(list()) 

    for line in lines:
        tokens = line.split(',')
        varname = tokens[0]
        vartokens = varname.split('_')
        fromsw = int(vartokens[0])
        tosw = int(vartokens[1])
        pid = int(vartokens[2])
        value = float(tokens[1])
        valuearr[fromsw][tosw].append([pid,value])
        weightarr[fromsw][tosw].append([pid,value])

    for fromsw in range(numsw):
        for tosw in range(numsw):
            if len(valuearr[fromsw][tosw])>0:
                valuesum = 0
                for _,value in valuearr[fromsw][tosw]:
                    valuesum += value
                valuetoweight = 1.0/valuesum
                for ipv,pv in enumerate(weightarr[fromsw][tosw]):
                    weightarr[fromsw][tosw][ipv][1] = pv[1] * valuetoweight

    for fromsw in range(numsw):
        for tosw in range(numsw):
            if len(weightarr[fromsw][tosw])>0:
                qweightarr[fromsw][tosw] = quantize_and_adjust_with_indices(weightarr[fromsw][tosw],factor)

    with open(qvarfile,'w') as f:
        for fromsw in range(numsw):
            for tosw in range(numsw):
                if len(qweightarr[fromsw][tosw])>0:
                    for pid,weight in qweightarr[fromsw][tosw]:
                        if weight>0:
                            f.write(f"{fromsw},{tosw},{pid},{weight}\n")









    # check qvarfile
    checkweightarr = list()
    for i in range(numsw):
        checkweightarr.append(list())
        for j in range(numsw):
            checkweightarr[i].append(0)
    with open(qvarfile,'r') as f:
        lines = f.readlines()
        for line in lines:
            tokens = line.split(',')
            fromsw = int(tokens[0])
            tosw = int(tokens[1])
            pid = int(tokens[2])
            weight = float(tokens[3])
            checkweightarr[fromsw][tosw] += weight

    for fromsw in range(numsw):
        for tosw in range(numsw):
            if checkweightarr[fromsw][tosw]!=0 and checkweightarr[fromsw][tosw]!=1:
                print(f"from {fromsw} to {tosw}: weight={checkweightarr[fromsw][tosw]}")