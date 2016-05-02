# Prepare environment ----------------------------------------------------------

# :og the price variables for log-log model -----------------------------------
heavy_log <- heavy[, grepl("price", colnames(heavy))] %>% 
  apply(2, log) %>% 
  cbind(heavy[, !grepl("price", colnames(heavy))]) %>% 
  select(-relweek)

# Step 2 - Set up models -------------------------------------------------------
# Set up overall regression for each brand using all variables
# n.b. the dot (".") syntax stands for "all other variables in the data")
# Log each sales (i.e. units) individual to achieve log-log model
carte <- lm(log(carte_noire_sales) ~ ., data = heavy)
douwe <- lm(log(douwe_egbert_sales) ~ ., data = heavy)
kenco <- lm(log(kenco_sales) ~ ., data = heavy)
nesca <- lm(log(nescafe_sales) ~ ., data = heavy)
other <- lm(log(other_brands_sales) ~ ., data = heavy)
super <- lm(log(supermarket_own_sales) ~ ., data = heavy)

# Stepwise regression to find best model for each brand
carte_fit <- step(carte, direction = "both", trace = FALSE)
douwe_fit <- step(douwe, direction = "both", trace = FALSE) 
kenco_fit <- step(kenco, direction = "both", trace = FALSE) 
nesca_fit <- step(nesca, direction = "both", trace = FALSE)
other_fit <- step(other, direction = "both", trace = FALSE)
super_fit <- step(super, direction = "both", trace = FALSE)

# Step 3 - Compute elasticities ------------------------------------------------
extract_elasticities_heavy <- function(model_fit) {
  # Extract tidy coefficients table from model
  coefs <- tidy(model_fit)
  
  # Helper function to extract the parameter for each brand's price
  extract_coef <- function(coef){
    coefs %>% 
      filter(term == coef) %>% 
      select(estimate) %>% 
      as.numeric()
  }
  
  # Use helper function to extract each brand's coefficients for the model
  carte_coef <- extract_coef("carte_noire_price") * mean(heavy$carte_noire_price)
  douwe_coef <- extract_coef("douwe_egbert_price") * mean(heavy$douwe_egbert_price)
  kenco_coef <- extract_coef("kenco_price") * mean(heavy$kenco_price)
  nesca_coef <- extract_coef("nescafe_price") * mean(heavy$nescafe_price)
  other_coef <- extract_coef("other_brands_price") * mean(heavy$other_brands_price)
  super_coef <- extract_coef("supermarket_own_price") * mean(heavy$supermarket_own_price)
  
  # Create matrix that stores results in known order
  results <- matrix(c(carte_coef, douwe_coef, kenco_coef, nesca_coef, 
                      other_coef, super_coef), nrow = 1)
  
  # Set column names
  colnames(results) <- c("carte", "douwe", "kenco", "nescafe", "other", "supermarket")
  
  # Return results
  return(results)
}

# Compute elasticities for each brand  
carte_elasts <- extract_elasticities_heavy(carte_fit)
douwe_elasts <- extract_elasticities_heavy(douwe_fit)
kenco_elasts <- extract_elasticities_heavy(kenco_fit)
nesca_elasts <- extract_elasticities_heavy(nesca_fit)
other_elasts <- extract_elasticities_heavy(other_fit)
super_elasts <- extract_elasticities_heavy(super_fit)

# Combine elasticities for each brand into single matrix
heavy_elasticities <- rbind(carte_elasts,
                            douwe_elasts,
                            kenco_elasts,
                            nesca_elasts,
                            other_elasts,
                            super_elasts)

# Set rownames to be the same as column names
rownames(heavy_elasticities) <- colnames(heavy_elasticities)

# Tidy up NA values to be 0
heavy_elasticities[is.na(heavy_elasticities)] <- 0

# Step 3 - Compute elasticity significances (as some may be insignificant) -----
extract_signifs <- function(model_fit) {
  # Extract tidy coefficients table from model
  coefs <- tidy(model_fit)
  
  # Helper function to extract the parameter for each brand's price
  extract_p <- function(coef){
    coefs %>% 
      filter(term == coef) %>% 
      select(p.value) %>% 
      as.numeric()
  }
  
  # Use helper function to extract each brand's coefficients for the model
  carte_p <- extract_p("carte_noire_price")
  douwe_p <- extract_p("douwe_egbert_price")
  kenco_p <- extract_p("kenco_price")
  nesca_p <- extract_p("nescafe_price")
  other_p <- extract_p("other_brands_price")
  super_p <- extract_p("supermarket_own_price")
  
  # Create matrix that stores results in known order
  results <- matrix(c(carte_p, douwe_p, kenco_p, nesca_p, other_p, super_p), 
                    nrow = 1)
  
  # Set column names
  colnames(results) <- c("carte", "douwe", "kenco", "nescafe", "other", "supermarket")
  
  # Return results
  return(results)
}

carte_signifs <- extract_signifs(carte_fit)
douwe_signifs <- extract_signifs(douwe_fit)
kenco_signifs <- extract_signifs(kenco_fit)
nesca_signifs <- extract_signifs(nesca_fit)
other_signifs <- extract_signifs(other_fit)
super_signifs <- extract_signifs(super_fit)

heavy_signifs <- rbind(carte_signifs,
                       douwe_signifs,
                       kenco_signifs,
                       nesca_signifs,
                       other_signifs,
                       super_signifs)

rownames(heavy_signifs) <- colnames(heavy_signifs)

heavy_signifs[heavy_signifs > 0.05] <- 0
heavy_signifs[heavy_signifs <= 0.05] <- 1
heavy_signifs[is.na(heavy_signifs)] <- 0


# Step 4 - Set elasticities = 0 if they are insignificant in the model, or NA --
heavy_elasticities_clean <- heavy_elasticities * heavy_signifs

# Step 5 - Clean up and garbage collect ----------------------------------------
objects <- ls()
idx <- grep("coffee_clean|heavy|light|heavy_log|heavy_elasticities_clean|normalise|toproper", objects)
objects <- objects[-idx]

rm(list = objects)
rm(objects, idx, heavy_elasticities, heavy_signifs, heavy_log)
gc()
