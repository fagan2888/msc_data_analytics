## 4: Office Supply Optimization w/additional supplier

# Decision variables: nb. of sets to buy from each supplier
var CW integer; #Caroline Woodworks
var NM integer; #Nashawtuc Millworks 
var AF integer; #Adirondack Furnishing Designs
var LA integer; #Lancaster Artisan Company
var DM1 integer; #Delaware Mills 0 <= DM1 <= 1000
var DM2 integer; #Delaware Mills 1001 <= DM2 <= 1500
var xcw binary;
var xnm binary;
var xaf binary;
var xla binary;
var xdm1 binary;
var xdm2 binary;

# Define objective function: Minimizing procurement costs
minimize costs: xcw * (10000 + 2500 * CW) + xnm * (20000 + 2450 * NM) 
		+ xaf * (0 + 2510 * AF) + xla * (13000 + 2470 * LA) +
		xdm1 * (9000 + 2530 * DM1) + 
		xdm2 * (7000 + 2430 * DM2);

# Constraints
#subject to need: xcw * CW + xnm* NM + xaf * AF + xla * LA + xdm1 * DM1 + xdm2 * DM2 = 2000;
subject to need: CW + NM + AF + LA + DM1 + DM2 = 2000;
subject to capacity1: CW <= 1000 * xcw;
subject to capacity2: NM <= 1200 * xnm;
subject to capacity3: AF <= 800 * xaf;
subject to capacity4: LA <= 1100 * xla;
subject to capacity5: DM1 <= 1000 * xdm1;
subject to capacity6: DM2 <= 500 * xdm2;
subject to depdiscount1: xdm1 - xdm2 >= 0;
#subject to depdiscount2: DM1 - DM2 >= 0;
subject to noneg1: CW >= 0;
subject to noneg2: NM >= 0;
subject to noneg3: AF >= 0;
subject to noneg4: LA >= 0;
subject to noneg5: DM1 >= 0;
subject to noneg6: DM2 >= 0;


# model morefurniture.mod; 
# option solver cplex;
# solve;

# display CW, NM, AF, LA, DM1, DM2, xcw, xnm, xaf, xla, xdm1, xdm2, costs;
