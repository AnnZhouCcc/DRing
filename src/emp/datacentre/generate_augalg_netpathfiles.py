import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--graphfile", type=str, default="", help="")
parser.add_argument("--numsw", type=int, default=0, help="")
parser.add_argument("--netpathfile", type=str, default="", help="")

args = parser.parse_args()

graphfile = args.graphfile
numsw = args.numsw
netpathfile = args.netpathfile








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

def bfs_shortest_path(adj_matrix, src, dst):
    """Return one shortest path from src to dst using BFS."""
    n = len(adj_matrix)
    visited = [False] * n
    parent = [-1] * n

    q = deque([src])
    visited[src] = True

    while q:
        u = q.popleft()
        if u == dst:
            break
        for v in range(n):
            if adj_matrix[u][v] == 1 and not visited[v]:
                visited[v] = True
                parent[v] = u
                q.append(v)

    # reconstruct path
    if not visited[dst]:
        return None  # no path

    path = []
    cur = dst
    while cur != -1:
        path.append(cur)
        cur = parent[cur]
    return list(reversed(path))


def all_pairs_shortest_paths(adj_matrix):
    """Return dict of (src, dst) -> shortest path list."""
    n = len(adj_matrix)
    paths = {}
    for i in range(n):
        for j in range(n):
            if i != j:
                paths[(i, j)] = bfs_shortest_path(adj_matrix, i, j)
    return paths


# Example usage
minpaths = all_pairs_shortest_paths(topologyarr)
# print(minpaths[(0, 3)])  # shortest path between node 0 and 3










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

        shortest_paths = []  # list of full paths (as list of vertices)
        queue_paths = deque()

        # start with source
        path_till_now = [src_sw]

        # get all possible first hops
        possible_first_hops = get_adjacent_vertices(src_sw)

        for next_hop in possible_first_hops:
            if next_hop == dest_sw:
                # direct path
                shortest_paths.append(path_till_now + [next_hop])
            else:
                # push path into queue for further expansion
                queue_paths.append(path_till_now + [next_hop])

        # BFS expansion
        while queue_paths:
            path_till_now = queue_paths.popleft()
            last_vertex = path_till_now[-1]
            possible_next_hops = get_adjacent_vertices(last_vertex)

            for next_hop in possible_next_hops:
                if next_hop in path_till_now:
                    continue  # Skip if this node is already in the path (prevents loops)
                if next_hop == dest_sw:
                    # found a shortest path!
                    shortest_paths.append(path_till_now + [next_hop])
                elif shortest_path_len[last_vertex][dest_sw] == 1 + shortest_path_len[next_hop][dest_sw]:
                    # still on shortest path, continue exploring
                    queue_paths.append(path_till_now + [next_hop])

        # Also add the canonical shortest path (Dijkstra or similar)
        shortest_path = minpaths[(src_sw, dest_sw)]  # assuming this exists
        if shortest_path not in shortest_paths:
            shortest_paths.append(shortest_path)

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