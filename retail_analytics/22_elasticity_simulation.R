## Research Project - Maria Athena B. Engesaeth
# 22_elasticity_simulation
#
# Prepare environment -----------------------------------------------------------------
# Clean up
rm(list = ls())

# Load demand function parameters
source("./20_demand_analysis.R")


# SIMULATE price changes --------------------------------------------------------------
attach(coffee)

# Simulate upward price change / increase the price in the data of one brand
# i.e. and measure the impact on demand.
# This is especially useful when there are lag effects present.

# CARTE NOIRE ----------------------------------
carte_up_price <- carte_noire_price * 1.10
carte_dwn_price <- carte_noire_price * 0.90
carte_coeff <- carte_excl_loss$coefficients

# Carte: upwards PED / Loss
carte_sim_loss_sales <- carte_coeff[1] + carte_coeff[2] * carte_up_price + 
  carte_coeff[3] * carte_noire_promo_cost + carte_coeff[4] * supermarketown_promo_cost
carte_up_elas <- ((carte_sim_loss_sales - carte_noire_sales) / carte_noire_sales)/ 1.10

# Carte: upwards PED / Loss
carte_sim_gain_sales <- carte_coeff[1] + carte_coeff[2] * carte_dwn_price + 
  carte_coeff[3] * carte_noire_promo_cost + carte_coeff[4] * supermarketown_promo_cost
carte_down_elas <- ((carte_sim_gain_sales - carte_noire_sales) / carte_noire_sales)/ 1.10

print(c("carte up elas: ", mean(carte_up_elas), sd(carte_up_elas)))
print(c("carte down elas: ", mean(carte_down_elas), sd(carte_down_elas)))



# DOUWE EGBERT ----------------------------------
douwe_up_price <- douwe_egbert_price * 1.10
douwe_dwn_price <- douwe_egbert_price * 0.90
douwe_coeff <- douwe_excl_loss$coefficients

# Douwe: upwards PED / Loss
douwe_sim_loss_sales <- douwe_coeff[1] + douwe_coeff[2] * douwe_up_price + 
  douwe_coeff[3] * kenco_price + douwe_coeff[4] * douwe_egbert_promo_cost + 
  douwe_coeff[5] * kenco_promo_cost + douwe_coeff[6] * supermarketown_promo_cost
douwe_up_elas <- ((douwe_sim_loss_sales - douwe_egbert_sales) / douwe_egbert_sales)/ 1.10

# Douwe: downpwards PED / Loss
douwe_sim_gain_sales <- douwe_coeff[1]  + douwe_coeff[2] * douwe_dwn_price + 
  douwe_coeff[3] * kenco_price + douwe_coeff[4] * douwe_egbert_promo_cost + 
  douwe_coeff[5] * kenco_promo_cost + douwe_coeff[6] * supermarketown_promo_cost
douwe_down_elas <- ((carte_sim_gain_sales - douwe_egbert_sales) / douwe_egbert_sales)/ 1.10


print(c("douwe up elas: (mean, sd)", mean(douwe_up_elas), sd(douwe_up_elas)))
print(c("douwe down elas: (mean, sd)", mean(douwe_down_elas), sd(douwe_down_elas)))



# Kenco -------------------------------------------
kenco_up_price <- kenco_price * 1.10
kenco_dwn_price <- kenco_price * 0.90
kenco_coeff <- kenco_excl_loss$coefficients

# Kenco: upwards PED / Loss
kenco_sim_loss_sales <- kenco_coeff[1] + kenco_coeff[2] * kenco_up_price + 
  kenco_coeff[3] * carte_noire_price + kenco_coeff[4] * carte_noire_promo_cost + 
  kenco_coeff[5] * otherbrands_price + kenco_coeff[6] * kenco_promo_cost + 
  kenco_coeff[7] * supermarketown_promo_cost
kenco_up_elas <- ((kenco_sim_loss_sales - kenco_sales) / kenco_sales)/ 1.10

# Kenco: downpwards PED / Loss
kenco_sim_gain_sales <- kenco_coeff[1] + kenco_coeff[2] * kenco_dwn_price + 
  kenco_coeff[3] * carte_noire_price + kenco_coeff[4] * carte_noire_promo_cost + 
  kenco_coeff[5] * otherbrands_price + kenco_coeff[6] * kenco_promo_cost + 
  kenco_coeff[7] * supermarketown_promo_cost
kenco_down_elas <- ((kenco_sim_gain_sales - kenco_sales) / kenco_sales)/ 1.10


print(c("kenco up elas: (mean, sd)", mean(kenco_up_elas), sd(kenco_up_elas)))
print(c("kenco down elas: (mean, sd)", mean(kenco_down_elas), sd(kenco_down_elas)))



# Nescafe -------------------------------------------
nescafe_up_price <- nescafe_price * 1.10
nescafe_dwn_price <- nescafe_price * 0.90
nescafe_coeff <- nesca_excl_loss$coefficients

# Nescafe: upwards PED / Loss
nescafe_sim_loss_sales <- nescafe_coeff[1] + nescafe_coeff[2] * nescafe_up_price + 
  nescafe_coeff[3] * nescafe_promo_cost + nescafe_coeff[4] * carte_noire_promo_cost + 
  nescafe_coeff[5] * kenco_promo_cost + nescafe_coeff[6] * supermarketown_promo_cost
nescafe_up_elas <- ((nescafe_sim_loss_sales - nescafe_sales) / nescafe_sales)/ 1.10

# Nescafe: downpwards PED / Loss
nescafe_sim_gain_sales <- nescafe_coeff[1] + nescafe_coeff[2] * nescafe_dwn_price + 
  nescafe_coeff[3] * nescafe_promo_cost + nescafe_coeff[4] * carte_noire_promo_cost + 
  nescafe_coeff[5] * kenco_promo_cost + nescafe_coeff[6] * supermarketown_promo_cost
nescafe_down_elas <- ((nescafe_sim_gain_sales - nescafe_sales) / nescafe_sales)/ 1.10


print(c("nescafe up elas: (mean, sd)", mean(nescafe_up_elas), sd(nescafe_up_elas)))
print(c("nescafe down elas: (mean, sd)", mean(nescafe_down_elas), sd(nescafe_down_elas)))



# Other Brands -------------------------------------------
other_up_price <- otherbrands_price * 1.10
other_dwn_price <- otherbrands_price * 0.90
other_coeff <- other_excl_loss$coefficients

# Nescafe: upwards PED / Loss
other_sim_loss_sales <- other_coeff[1] + other_coeff[2] * other_up_price + 
  other_coeff[3] * otherbrands_promo_cost + other_coeff[4] * supermarketown_promo_cost
other_up_elas <- ((other_sim_loss_sales - otherbrands_sales) / otherbrands_sales)/ 1.10

# Nescafe: downpwards PED / Loss
other_sim_gain_sales <- other_coeff[1] + other_coeff[1] * other_dwn_price + 
  other_coeff[3] * otherbrands_promo_cost + other_coeff[4] * supermarketown_promo_cost
other_down_elas <- ((other_sim_gain_sales - otherbrands_sales) / otherbrands_sales)/ 1.10


print(c("other up elas: (mean, sd)", mean(other_up_elas), sd(other_up_elas)))
print(c("other down elas: (mean, sd)", mean(other_down_elas), sd(other_down_elas)))




# Supermarket Own -------------------------------------------
super_up_price <- supermarketown_price * 1.10
super_dwn_price <- supermarketown_price * 0.90
super_coeff <- super_excl_loss$coefficients

# Nescafe: upwards PED / Loss
super_sim_loss_sales <- super_coeff[1] + super_coeff[2] * super_up_price + 
  super_coeff[3] * otherbrands_price + super_coeff[4] * carte_noire_promo_cost +
  super_coeff[5] * nescafe_promo_cost + super_coeff[6] * supermarketown_promo_cost
super_up_elas <- ((super_sim_loss_sales - supermarketown_sales) / supermarketown_sales)/ 1.10

# Nescafe: downpwards PED / Loss
super_sim_gain_sales <- super_coeff[1] + super_coeff[2] * super_dwn_price + 
  super_coeff[3] * otherbrands_price + super_coeff[4] * carte_noire_promo_cost +
  super_coeff[5] * nescafe_promo_cost + super_coeff[6] * supermarketown_promo_cost
super_down_elas <- ((super_sim_gain_sales - supermarketown_sales) / supermarketown_sales)/ 1.10


print(c("super up elas: (mean, sd)", mean(super_up_elas), sd(super_up_elas)))
print(c("super down elas: (mean, sd)", mean(super_down_elas), sd(super_down_elas)))


