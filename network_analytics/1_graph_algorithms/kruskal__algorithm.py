# -*- coding: utf-8 -*-
"""
Created on Sat Nov 21

@author: MariaAthena
"""

wdir = ('/Users/MariaAthena/Dropbox/00 Imperial College/Network Analytics/Assignment 1')
graph_file = ('HW1_3.txt')

Graph = {}
Nodes = {}


# Code that helps define the graph that makes up the tree of maximum weight and
# The find_edge and union functions ensures no cycles are created by starting
# at a hitherto non existing value on the graph then only adding new_nodes that
#  are not already part of the graph.
class MaxTree():

    def __init__(self, new_value):
        self.parent = -1
        self.value = new_value

    def find_edge(self):
        if self.parent == -1:
            return self.value
        else:
            return self.parent.find_edge()
    
    def union(self, new_node):
        current_root = self.find_edge()
        new_root = new_node.find_edge()
        Nodes[current_root].parent = Nodes[new_root]



# Creates the graph in dictionary form: {'u': [('v', w)]} from text file
# where each key is the node and the values aare the edges and their weighting
with open(graph_file, 'r') as input:
    for line in input.readlines():
        l_stripped = line.strip().split(' ')
        key = l_stripped[0]
        if (not key in Graph):
            Graph[key] = []
        Nodes[key] = MaxTree(key)
        Nodes[l_stripped[1]] = MaxTree(l_stripped[1])
        Graph[key].append((l_stripped[1], float(l_stripped[2])))



# Orders dictionary by the weighting and puts it in list
def sort_graph(unsorted_graph):
    dict = Graph
    edges = []
    for k, v in dict.items():
        for edge in v:
            new_edge = (edge[1], edge[0], k)
            edges.append(new_edge)
    edges.sort(reverse=True)
    return edges



# Implement Kruskal's algorithm
def kruskal(a_graph):
    edges = sort_graph(a_graph)
    kruskal_graph = {}
    for (w, node1, node2) in edges:
        if Nodes[node1].find_edge() != Nodes[node2].find_edge():
            if not kruskal_graph.has_key(node1):
                kruskal_graph[node1] = []
            kruskal_graph[node1].append((node2, w))
            Nodes[node1].union(Nodes[node2])
    return kruskal_graph
    


#print Graph
sort_graph(Graph)
kruskal_graph = kruskal(Graph)
print kruskal_graph

