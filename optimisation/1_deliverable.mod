### Assignment 1 - Optimisation & Decision Models
###
### Maria Athena B Engesaeth
### CID 01159179


## Ex2: Production Plan Problem for Food Company


# Define the decision variables:
var STF;	# number of Stir Fry bags to produce
var BBQ;	# number of Barbecue bags to produce
var HMU;	# number of Hearty Mushrooms bags to produce
var VGC;	# number of Veggie Crunch bags to produce


# Objective function:
maximize revenue: 0.22 * STF + 0.20 * BBQ + 0.18 * HMU + 0.18 * VGC;

# Problem is subject to the constraints:
subject to carrots: 62.5 * STF + 50 * BBQ + 62.5 * VGC <= 3750000;
subject to mushrooms: 75 * STF + 100 * HMU <= 2000000;
subject to greenpeppers: 62.5 * STF + 50 * BBQ + 75 * HMU + 62.5 * VGC <= 3375000;
subject to broccoli: 50 * STF + 75 * BBQ + 75 * HMU + 62.5 * VGC <= 3500000;
subject to corn: 75 * BBQ + 62.5 * VGC <= 3750000;
subject to nonneg1: STF >= 0;
subject to nonneg2: BBQ >= 0;
subject to nonneg3: HMU >= 0;
subject to nonneg4: VGC >= 0;

# model easy.mod;
# solve;
# display STF, BBQ, HMU, VGC;

#option solver cplex;
#option cplex_options 'sensitivity';
#solve;

# display greenpeppers;

# display greenpeppers.down, greenpeppers.current, greenpeppers.up;