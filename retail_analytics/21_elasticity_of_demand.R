## Research Project - Maria Athena B. Engesaeth
# 21_elasticity_of_demand
#
# Prepare environment -----------------------------------------------------------------
# Clean up
rm(list = ls())

# Load demand function parameters
source("./20_demand_analysis.R")

# Compute elasticities ----------------------------------------------------------------
extract_elasticities <- function(model_fit) {
  # Extract coefficients table from model
  coefs <- tidy(model_fit)
  
  # Helper function to extract the parameter for each brand's price
  extract_coef <- function(coef){
    coefs %>% 
      filter(term == coef) %>% 
      select(estimate) %>% 
      as.numeric()
  }
  
  # Use helper function to extract each brand's coefficients for the model
  carte_coef <- extract_coef("carte_noire_price") * mean(coffee$carte_noire_price)
  douwe_coef <- extract_coef("douwe_egbert_price") * mean(coffee$douwe_egbert_price)
  kenco_coef <- extract_coef("kenco_price") * mean(coffee$kenco_price)
  nesca_coef <- extract_coef("nescafe_price") * mean(coffee$nescafe_price)
  other_coef <- extract_coef("otherbrands_price") * mean(coffee$otherbrands_price)
  super_coef <- extract_coef("supermarketown_price") * mean(coffee$supermarketown_price)
  
  # Create matrix that stores results in known order
  results <- matrix(c(carte_coef, douwe_coef, kenco_coef, nesca_coef, 
                      other_coef, super_coef), nrow = 1)
  
  # Set column names
  colnames(results) <- c("carte", "douwe", "kenco", "nescafe", "other", "supermarket")
  
  # Return results
  return(results)
}



# Compute own & cross price elasticity for each brand EXCL loss --------------------------

carte_el_exloss <- extract_elasticities(carte_excl_loss)
douwe_el_exloss <- extract_elasticities(douwe_excl_loss)
kenco_el_exloss <- extract_elasticities(kenco_excl_loss)
nesca_el_exloss <- extract_elasticities(nesca_excl_loss)
other_el_exloss <- extract_elasticities(other_excl_loss)
super_el_exloss <- extract_elasticities(super_excl_loss)

# Combine elasticities for each brand into single matrix
elasticities_exloss <- rbind(carte_el_exloss[1],
                             douwe_el_exloss[2],
                             kenco_el_exloss[3],
                             nesca_el_exloss[4],
                             other_el_exloss[5],
                             super_el_exloss[6])

# Set rownames to be the same as column names
rownames(elasticities_exloss) <- c("carte", "douwe", "douwe", "nesca", "other", "super")

# Tidy up NA values to be 0
elasticities_exloss[is.na(elasticities_exloss)] <- 0


# Compute own price elasticity for each brand INCL loss --------------------------------

carte_el_wloss <- extract_elasticities(carte_incl_loss)
douwe_el_wloss <- extract_elasticities(douwe_incl_loss)
kenco_el_wloss <- extract_elasticities(kenco_incl_loss)
nesca_el_wloss <- extract_elasticities(nesca_incl_loss)
other_el_wloss <- extract_elasticities(other_incl_loss)
super_el_wloss <- extract_elasticities(super_incl_loss)

# Combine elasticities for each brand into single matrix
elasticities_wloss <- rbind(carte_el_wloss[1],
                            douwe_el_wloss[2],
                            kenco_el_wloss[3],
                            nesca_el_wloss[4],
                            other_el_wloss[5],
                            super_el_wloss[6])

# Set rownames to be the same as column names
rownames(elasticities_wloss) <- c("carte", "douwe", "douwe", "nesca", "other", "super")
# Tidy up NA values to be 0
elasticities_wloss[is.na(elasticities_wloss)] <- 0


# Clean up ----------------------------------------------------------------------------
# rm(list = ls())

