from __future__ import print_function
import numpy as np
import random
import json
import sys
import os
import ast
import networkx as nx
from networkx.readwrite import json_graph
version_info = list(map(int, nx.__version__.split('.')))
major = version_info[0]
minor = version_info[1]
assert (major <= 1) and (minor <= 11), "networkx major version > 1.11"

WALK_LEN = 5
N_WALKS = 50


def run_random_walks(G, nodes, num_walks=N_WALKS):
    pairs = []
    for count, node in enumerate(nodes):
        if G.degree(node) == 0:
            continue
        for i in range(num_walks):
            curr_node = node
            for j in range(WALK_LEN):
                next_node = random.choice(G.neighbors(curr_node))
                # self co-occurrences are useless
                if curr_node != node:
                    pairs.append((node, curr_node))
                curr_node = next_node
        if count % 1000 == 0:
            print("Done walks for", count, "nodes")
    return pairs


prefix = '../ckd_input_data/ckd'

G_data = json.load(open(prefix + "-G.json"))
a1 = ast.literal_eval(G_data['nodes'])
ab1 = list(a1)
G_data['nodes'] = ab1
b1 = ast.literal_eval(G_data['links'])
ab2 = list(b1)
G_data['links'] = ab2
G = json_graph.node_link_graph(G_data)

nodes = [
    n for n in G.nodes() if not G.node[n]["val"] and not G.node[n]["test"]
]
G = G.subgraph(nodes)
pairs = run_random_walks(G, nodes)

out_file = prefix + '-walks.txt'
with open(out_file, "w") as fp:
    fp.write("\n".join([str(p[0]) + "\t" + str(p[1]) for p in pairs]))
