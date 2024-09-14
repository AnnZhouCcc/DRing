korn = 3
routing = "su3"
graphname = "rrg"
swlist = range(40,121,20)
svrlist = [752,1680,2992,4672,6720]

for inumsw,numsw in enumerate(swlist):
    
    # numserver = svrlist[inumsw]
    numserver = (numsw//5)*(numsw//5)*12
    numport = int(numsw*0.8)

    homedir = "/home/annzhou/"
    # graphfile = f"{homedir}DRing/src/emp/datacentre/graphfiles/ring_supergraph/double_ring/instance1_{numsw}_{numport}.edgelist"
    # graphfile = f"{homedir}DRing/src/emp/datacentre/scalegraphfiles/{graphname}_deg{numport}_sw{numsw}_sn12_i1.edgelist"
    graphfile = f"{homedir}DRing/src/emp/datacentre/scalegraphfiles/{graphname}_deg{numport}_sw{numsw}_svr{numserver}_os1_i1.edgelist"
    netpathfile = f"{homedir}DRing/src/emp/datacentre/netpathfiles/netpath_{routing}_{graphname}_{numserver}_{numsw}_{numport}"









    # read topology
    topologyarr = list()
    for i in range(numsw):
        topologyarr.append(list())
        for j in range(numsw):
            topologyarr[i].append(0)
    with open(graphfile,'r') as f:
        lines = f.readlines()
        for line in lines:
            tokens = line.split("->")
            srcsw = int(tokens[0])
            dstsw = int(tokens[1])
            topologyarr[srcsw][dstsw] = 1
            topologyarr[dstsw][srcsw] = 1








    # floydWarshall()
    shortest_path_len = list()
    for i in range(numsw):
        shortest_path_len.append(list())
        for j in range(numsw):
            shortest_path_len[i].append(1000000)

    for i in range(numsw):
        for j in range(numsw):
            if topologyarr[i][j] == 1:
                shortest_path_len[i][j] = 1

    for k in range(numsw):
        for i in range(numsw):
            for j in range(numsw):
                if shortest_path_len[i][j] > shortest_path_len[i][k] + shortest_path_len[k][j]:
                    shortest_path_len[i][j] = shortest_path_len[i][k] + shortest_path_len[k][j]








    from collections import deque

    def get_adjacent_vertices(vertex):
        adjacenylist = list()
        for i in range(numsw):
            if topologyarr[vertex][i] == 1:
                adjacenylist.append(i)
        return adjacenylist

    net_paths_rack_based = list()
    for i in range(numsw):
        net_paths_rack_based.append(list())
        for j in range(numsw):
            net_paths_rack_based[i].append(list())

    for src_sw in range(numsw):
        for dest_sw in range(numsw):

            if src_sw == dest_sw: continue

            shortest_paths = []
            shortest_paths_till_now = deque()

            path_till_now = [src_sw]
            shortest_paths_till_now.append(path_till_now)

            while len(shortest_paths_till_now)>0:
                path_till_now = shortest_paths_till_now.popleft()
                last_vertex = path_till_now[-1]
                possible_next_hops = get_adjacent_vertices(last_vertex)

                for next_hop in possible_next_hops:
                    if next_hop == dest_sw:
                        # Found a shortest path!
                        shortest_path = path_till_now + [next_hop]
                        shortest_paths.append(shortest_path)

                    # Check if we can extend the path
                    elif len(path_till_now) <= (korn - 1):
                        new_hop = True
                        for hop in path_till_now:
                            if hop == next_hop:
                                new_hop = False
                        if new_hop:
                            shortest_path_till_now = path_till_now + [next_hop]
                            shortest_paths_till_now.append(shortest_path_till_now)

                    # Evaluate only for shortest paths
                    elif shortest_path_len[src_sw][dest_sw] == (len(path_till_now) - 1) + shortest_path_len[last_vertex][dest_sw] and shortest_path_len[last_vertex][dest_sw] == 1 + shortest_path_len[next_hop][dest_sw]:
                        shortest_path_till_now = path_till_now + [next_hop]
                        shortest_paths_till_now.append(shortest_path_till_now)

            # # Process the shortest paths
            # paths_rack_based = []
            # for path in shortest_paths:
            #     route_out = []
                
            #     for hop in range(1, len(path)):
            #         fr = path[hop - 1].get_id()
            #         to = path[hop].get_id()
            #         route_out.append(queues_sw_sw[fr][to])
            #         route_out.append(pipes_sw_sw[fr][to])
                
            #     paths_rack_based.append(route_out)
            #     check_non_null(route_out)  # Assuming this function is defined elsewhere

            # net_paths_rack_based[src_sw][dest_sw] = paths_rack_based
            net_paths_rack_based[src_sw][dest_sw] = shortest_paths









    with open(netpathfile,'w') as f:
        for i in range(numsw):
            for j in range(numsw):
                if i==j:
                    f.write(f"{i} {j} 0\n")
                else:
                    paths_rack_based = net_paths_rack_based[i][j]
                    f.write(f"{i} {j} {len(paths_rack_based)}\n")
                    for path in paths_rack_based:
                        for ihop in range(1,len(path)):
                            f.write(f" {path[ihop-1]}->{path[ihop]}")
                        f.write("\n")