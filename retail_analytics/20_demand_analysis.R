# Research Project - Maria Athena B. Engesaeth
# 20_demand_analysis_everyone
#
# Prepare working environment ---------------------------------------------------

# Clean up
rm(list = ls())

library(readr)
library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select
library(mlogit)
library(broom)
#library(countreg)

# Load parsed, filtered and cleaned data ----------------------------------------

coffee <- read.csv("./Data/wide_everyone.csv",
# coffee <- read.csv("./Data/wide_only_heavy.csv
# coffee <- read.csv("./Data/wide_only_light.csv",
                   encoding = "latin1", 
                   stringsAsFactors = FALSE, row.names=NULL) %>% 
  as_data_frame()


# log the price variables for log-log model
coffee <- coffee[, grepl("price", colnames(coffee))] %>% 
  apply(2, log) %>% 
  cbind(coffee[, !grepl("price", colnames(coffee))]) %>% 
  select(-day) %>% 
  na.omit()


# Chosing the best fit model for the demand functions ----------------------------------

carte_excl_loss <- lm(log(carte_noire_sales) ~ carte_noire_price + carte_noire_promo_cost +
                        supermarketown_promo_cost, data = coffee)
# summary(carte_excl_loss)

douwe_excl_loss <- lm(log(douwe_egbert_sales) ~ douwe_egbert_price + kenco_price +
                        douwe_egbert_promo_cost + kenco_promo_cost +
                        supermarketown_promo_cost, data = coffee)
# summary(douwe_excl_loss)

kenco_excl_loss <- lm(log(kenco_sales) ~ kenco_price + carte_noire_price +
                        carte_noire_promo_cost + otherbrands_price + 
                        kenco_promo_cost + otherbrands_promo_cost + 
                        supermarketown_promo_cost, data = coffee)
# summary(kenco_excl_loss)

nesca_excl_loss <- lm(log(nescafe_sales) ~ nescafe_price + nescafe_promo_cost +
                        carte_noire_promo_cost + kenco_promo_cost + 
                        supermarketown_promo_cost, data = coffee)
# summary(nesca_excl_loss)

other_excl_loss <- lm(log(otherbrands_sales) ~ otherbrands_price + otherbrands_promo_cost +
                        supermarketown_promo_cost, data = coffee)
# summary(other_excl_loss)

super_excl_loss <- lm(log(supermarketown_sales) ~ supermarketown_price + otherbrands_price +
                        carte_noire_promo_cost + nescafe_promo_cost +
                        supermarketown_promo_cost, data = coffee)
# summary(super_excl_loss)


# Adding the LOSS to the best fit of the demand functions --------------------------------

carte_incl_loss <- lm(log(carte_noire_sales) ~ carte_noire_price + carte_noire_promo_cost +
                        supermarketown_promo_cost + carte_noire_cons_loss, data = coffee)
# summary(carte_incl_loss)

douwe_incl_loss <- lm(log(douwe_egbert_sales) ~ douwe_egbert_price + kenco_price +
                        douwe_egbert_promo_cost + kenco_promo_cost +
                        supermarketown_promo_cost + douwe_egbert_cons_loss, data = coffee)
# summary(douwe_incl_loss)

kenco_incl_loss <- lm(log(kenco_sales) ~ kenco_price + carte_noire_price +
                        otherbrands_price + otherbrands_promo_cost + 
                        supermarketown_promo_cost + kenco_cons_loss, data = coffee)
# summary(kenco_incl_loss)

nesca_incl_loss <- lm(log(nescafe_sales) ~ nescafe_price + nescafe_promo_cost +
                        carte_noire_promo_cost + kenco_promo_cost + 
                        supermarketown_promo_cost + nescafe_cons_loss, data = coffee)
# summary(nesca_incl_loss)

other_incl_loss <- lm(log(otherbrands_sales) ~ otherbrands_price + otherbrands_promo_cost +
                        supermarketown_promo_cost + other_brands_cons_loss, data = coffee)
# summary(other_incl_loss)

super_incl_loss <- lm(log(supermarketown_sales) ~ supermarketown_price + otherbrands_price +
                        carte_noire_promo_cost + nescafe_promo_cost + 
                        supermarketown_promo_cost + supermarket_own_cons_loss, data = coffee)
# summary(super_incl_loss)



# Find best fit for demand function per brand ----------------------------------------

# Coffee dataframe excl. the LOSS columns
# coffee_ex_loss <- coffee %>%
#   select(-carte_noire_cons_loss, -douwe_egbert_cons_loss, -kenco_cons_loss,
#          -nescafe_cons_loss, -other_brands_cons_loss, -supermarket_own_cons_loss,
#          -relweek, -carte_noire_sales, -douwe_egbert_sales, -kenco_sales,
#          -nescafe_sales, -otherbrands_sales)
# -supermarketown_sales

# Set up overall regression for each brand using all variables
# n.b. the dot (".") syntax stands for "all other variables in the data")
# Log each sales (i.e. units) individual to achieve log-log model
# carte <- lm(log(carte_noire_sales) ~ ., data = coffee_ex_loss)
# douwe <- lm(log(douwe_egbert_sales) ~ ., data = coffee_ex_loss)
# kenco <- lm(log(kenco_sales) ~ ., data = coffee_ex_loss)
# nesca <- lm(log(nescafe_sales) ~ ., data = coffee_ex_loss)
# other <- lm(log(otherbrands_sales) ~ ., data = coffee_ex_loss)
# super <- lm(log(supermarketown_sales) ~ ., data = coffee_ex_loss)
# 
# # Stepwise regression to find best model for each brand
# carte_fit <- step(carte, direction = "both", trace = FALSE)
# douwe_fit <- step(douwe, direction = "both", trace = FALSE) 
# kenco_fit <- step(kenco, direction = "both", trace = FALSE) 
# nesca_fit <- step(nesca, direction = "both", trace = FALSE)
# other_fit <- step(other, direction = "both", trace = FALSE)
# super_fit <- step(super, direction = "both", trace = FALSE)

# Output results from stepwise regression
# summary(carte_fit)
# summary(douwe_fit)
# summary(kenco_fit)
# summary(nesca_fit)
# summary(other_fit)
# summary(super_fit)
