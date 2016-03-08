# -*- coding: utf-8 -*-
"""
Created on Sat Dec  5

HW2: MAX FLOW IN DIRECTED GRAPH

@author: MariaAthena
"""

# import sys
# sys.path.append('Library/Python/2.7/site-packages/pulp/pulp.py')
from pulp import *


# declare variables and constraints
E1 = LpVariable("E1", 0, 5, cat='Integer')   # 0<= E1 <= 5
E2 = LpVariable("E2", 0, 13, cat='Integer')  # 0<= E2 <= 13
E3 = LpVariable("E3", 0, 3, cat='Integer')  # 0<= E3 <= 3
E4 = LpVariable("E4", 0, 7, cat='Integer')  # 0<= E4 <= 7
E5 = LpVariable("E5", 0, 5, cat='Integer')  # 0<= E5 <= 5
E6 = LpVariable("E6", 0, 3, cat='Integer')  # 0<= E6 <= 3
E7 = LpVariable("E7", 0, 2, cat='Integer')  # 0<= E7 <= 2
E8 = LpVariable("E8", 0, 2, cat='Integer')  # 0<= E8 <= 2
E9 = LpVariable("E9", 0, 4, cat='Integer')  # 0<= E9 <= 4
E10 = LpVariable("E10", 0, 9, cat='Integer')  # 0<= E10 <= 9
E11 = LpVariable("E11", 0, 5, cat='Integer')  # 0<= E11 <= 5
E12 = LpVariable("E12", 0, 10, cat='Integer')  # 0<= E12 <= 10
f = LpVariable("f", lowBound=0, cat='Integer')  # 0<= f <= E12 + E11

# defines the problem
flow = LpProblem("flow", LpMaximize)


# Defines the capacity constraints
flow += f - (E12 + E11) <= 0
flow += f - (E1 + E2 + E3) <= 0
flow += E6 - (E1 + E4) == 0
flow += E7 - (E3) == 0
flow += E8 - (E3) == 0
flow += E9 - (E3 + E5) == 0
flow += E10 - (E8 + E9) == 0
flow += E11 - (E6 + E7 + E10) == 0
flow += E12 - (E8 + E9) == 0


# defines the objective function to maximize
flow += f, "Maximise flow in from S to T"

# solve the problem
flow.solve()
status = flow.solve(GLPK(msg=0))
LpStatus[status]

# print the results -> i.e. edges and flow amounts to send into them
print "E1 = ", value(E1)
print "E2 = ", value(E2)
print "E3 = ", value(E3)
print "E4 = ", value(E4)
print "E4 = ", value(E5)
print "E6 = ", value(E6)
print "E7 = ", value(E7)
print "E8 = ", value(E8)
print "E9 = ", value(E9)
print "E10 = ", value(E10)
print "E11 = ", value(E11)
print "E12 = ", value(E12)
print "Total flow arriving at T = ", (value(E11) + value(E12))
print "Status: ", LpStatus[status]
