## 4: Office Supply Optimization

# Decision variables: nb. of sets to buy from each supplier
var CW; #Caroline Woodworks
var NM; #Nashawtuc Millworks 
var AF; #Adirondack Furnishing Designs
var LA; #Lancaster Artisan Company
var x1 binary;
var x2 binary;
var x3 binary;
var x4 binary;


# Define objective function: Minimizing procurement costs
minimize costs: x1 * (10000 + 2500 * CW) + x2 * (20000 + 2450 * NM) 
		+ x3 * (0 + 2510 * AF) + x4 * (13000 + 2470 * LA);


# Constraints
subject to CW + NM + AF + LA = 2000;
subject to CW <= 1000;
subject to NM <= 1200;
subject to AF <= 800;
subject to LA <= 1100;
subject to CW >= 0;
subject to NM >= 0;
subject to AF >= 0;
subject to LA >= 0;


# model furniture.mod; 
# solve;

# display CW, NM, AF, LA;
