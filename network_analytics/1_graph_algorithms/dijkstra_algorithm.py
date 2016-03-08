# -*- coding: utf-8 -*-
"""
Created on Wed Nov 25 2015

@author: MariaAthena
    """

from operator import itemgetter

graph_file = ('/Users/MariaAthena/Dropbox/00 Imperial College/Network Analytics/Assignment 1/HW1_4.txt')

Nodes = set()

# Converting .TXT file containing graph into datatypes readible in python
def create_graph(a_file):
    with open(graph_file, 'r') as input:
        for line in input.readlines():
            element = line.strip().split(' ')
        
            # convert elements from each line in text file into new data types
            node1 = int(element[1])
            node2 = int(element[0])
            weight = float(element[2])
        
            # create tuples containing (u, v, w)
            if (not node1 in Nodes):
                Nodes.add((node1, node2, weight))
        return Nodes



# Helper functions

# Here we are examining which nodes neighbor a certain node
def the_neighbours(node):
    neighbours = []    
    for t in Nodes:
        
        if t[1] == node:
            neighbours.append(t)
        elif t[0] == node:
            neighbours.append(t)
    return neighbours

# Given the list of neighbours, we now select the one that has the lowest
# weight on the edge leading to that node, i.e. the closest_neighbour
def the_closest(neighbours, node):
    the_flanders = the_neighbours(node)
    ned_flanders = min(the_flanders, key=itemgetter(2))
    return ned_flanders



# To implement Dijkstras algorithm we need to define a set of variables and
# data types so that we can evaluate the edges individually as being 
# connected to the node we are positioned at as well as being parth of the Graph
# as a whole. G(u, v, w):
def dijkstras(Nodes, start, destination):
    Graph = Nodes
    end = destination
    dijkstras_path = set()

#    # Sanity Check 1:
#    if start not in n:
#        return TypeError("You're starting node is not in the loaded Graph")
#    # Sanity Check 2:
#    elif end not in n:
#        return TypeError("You're destination node is not in the loaded Graph")
#    # Sanity Check 3:
#    elif  start == end:
#        return []
#        print "The shortest path from %s to %s is an empty set." (start, destination)

    previous_node = start
    while previous_node != end:
        poss_destination = the_neighbours(previous_node)
        go_here = the_closest(poss_destination, previous_node)
        dijkstras_path.add(go_here)
        Graph.remove(go_here)
        previous_node = go_here[1]
    return dijkstras_path


# dictionary distances from source
# dict of predecessors


###############################################################################
# EVENT HANDLERS TO SET OF THE ALGORTHM
# AND TEXT TO BE PRINTED IN THE CONSOLE FOR THE USER
###############################################################################

all_nodes = create_graph(graph_file)
list_node = list(all_nodes)
# Print info from the loaded graph file
print "Here are the nodes contained in the graph:"
print all_nodes


# Prompt user for desired start, end node to find shortest path to
print "What node should be the starting point?"
first = int(raw_input('> '))
print "What node should be the destination?"
end = int(raw_input('> '))

shortest_path = dijkstras(all_nodes, first, end)

print "The shortest path from %s to %s according to Dijsktra  is the following:" % (first, end)
print shortest_path
