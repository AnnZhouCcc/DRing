import sys
import networkx as nx
from graphviz import Digraph

if not len(sys.argv) == 3: 
	print("Required number of arguments: 3.", len(sys.argv)-1, "provided")
	print("Arguments: <network_file> <out_file>")
	sys.exit()

network_file = sys.argv[1]
out_file = sys.argv[2]

G = nx.Graph()
def tuple_string_link(u, v):
    return "L("+str(u)+","+str(v)+")"

def tuple_string_flow(u, v):
    return "F("+str(u)+","+str(v)+")"

def tuple_string_path(u, v, i):
    u = host_rack_map[u]
    v = host_rack_map[v]
    return "P("+str(u)+","+str(v)+","+str(i)+")"

gv_graph = Digraph(format='png', filename=out_file)
host_rack_map = dict()
host_offset = 10000
nservers = 0
gv_link_flow_set = set()
with open(network_file) as nf:
    for line in nf:
        if "->" in line:
            tokens = line.split("->")
            host = int(tokens[0])
            rack = int(tokens[1])
            G.add_edge(host+host_offset, rack)
            nservers += 1
            host_rack_map[host] = rack
            #print(host, rack)
        else:
            tokens = line.split()
            rack1 = int(tokens[0])
            rack2 = int(tokens[1])
            gv_graph.node(str(rack1))
            gv_graph.node(str(rack2))
            gv_graph.edge(str(rack1), str(rack2))

print("Finished constructing the graph")
gv_graph.render(out_file)  
#gv_graph.view()
