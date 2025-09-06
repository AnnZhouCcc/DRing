# Read in parameters
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--numsw", type=int, default=0, help="")
parser.add_argument("--netpathfile", type=str, default="", help="")
parser.add_argument("--qvarfile", type=str, default="", help="")

args = parser.parse_args()

numsw = args.numsw
netpathfile = args.netpathfile
qvarfile = args.qvarfile

factor = 64











from collections import defaultdict

def maxmin_path_capacities_equal(paths, C=1.0, directed=False, eps=1e-12):
    """
    Max-min fair 'path capacities' for a single s->t demand when all links have the same capacity C.
    paths: list of paths; each path is a list of edges, where an edge is a 2-tuple (u,v).
    C: link capacity (uniform). Results are in absolute units; ratios don't depend on C.
    directed: if False, edges are normalized so ('a','b') == ('b','a').
    """
    def norm(e):
        return e if directed else tuple(sorted(e))

    # edge -> set of path indices that use it
    edge_to_paths = defaultdict(set)
    for i, p in enumerate(paths):
        for e in map(norm, p):
            edge_to_paths[e].add(i)

    # Residual capacity is 1 for every edge (since all are equal); scale by C at the end
    cres = {e: 1.0 for e in edge_to_paths}    # residual capacities (unit)
    active = set(range(len(paths)))           # paths not yet frozen
    f = [0.0] * len(paths)                    # path rates (unit)

    while active:
        # m_e: number of active paths using edge e
        me = {e: len(edge_to_paths[e] & active) for e in edge_to_paths}
        # delta: how much we can raise all active paths uniformly before some edge saturates
        candidates = [cres[e] / me[e] for e in edge_to_paths if me[e] > 0]
        if not candidates:
            break
        delta = min(candidates)

        # Raise every active path by delta
        for i in active:
            f[i] += delta

        # Decrease residual edge capacities; find newly saturated edges
        newly_sat = set()
        for e, m in me.items():
            if m > 0:
                cres[e] -= delta * m
                if cres[e] <= eps:
                    cres[e] = 0.0
                    newly_sat.add(e)

        # Freeze any active path that touches a newly saturated edge
        to_freeze = {i for e in newly_sat for i in (edge_to_paths[e] & active)}
        active -= to_freeze

    # Scale back to absolute units
    return [C * x for x in f]

# Example
# if __name__ == "__main__":
    # Three paths between s and t; P1 and P3 share edge (a,b)
    # P1 = [('s','a'), ('a','b'), ('b','t')]
    # P2 = [('s','c'), ('c','t')]
    # P3 = [('s','a'), ('a','b'), ('b','d'), ('d','t')]
    # paths = [P1, P2, P3]
    # print(maxmin_path_capacities_equal(paths, C=10.0))  # e.g., [5.0, 10.0, 5.0]







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








pathweights = list()
for i in range(numsw):
    pathweights.append(list())
    for j in range(numsw):
        pathweights[i].append(list())
for fromsw in range(numsw):
    for tosw in range(numsw):
        if fromsw != tosw:
            if len(netpath[fromsw][tosw]) == 0:
                print(f"Error: no path from {fromsw} to {tosw}")
            else:
                paths = list()
                for path in netpath[fromsw][tosw]:
                    edges = list()
                    for i in range(len(path)-1):
                        edges.append( (path[i], path[i+1]) )
                    paths.append(edges)
                weights = maxmin_path_capacities_equal(paths, C=1.0)
                pathweights[fromsw][tosw] = weights









########################
# Quantize
########################

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

for fromsw in range(numsw):
    for tosw in range(numsw):
        if len(pathweights[fromsw][tosw])>0:
            for pid in range(len(pathweights[fromsw][tosw])):
                valuearr[fromsw][tosw].append([pid,pathweights[fromsw][tosw][pid]])
                weightarr[fromsw][tosw].append([pid,pathweights[fromsw][tosw][pid]])

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

