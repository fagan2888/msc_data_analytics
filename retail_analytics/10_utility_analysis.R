# Research Project - Maria Athena B. Engesaeth
# 10_utility_analysis
#
# Prepare working environment---------------------------------------------------

# Clean up
rm(list = ls())

library(readr)
library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select
library(mlogit)


# Load parsed, filtered and cleaned --------------------------------------------

# coffee <- read.csv("./Data/long_mlogit_readable.csv",
# coffee <- read.csv("./Data/long_data2.csv",
coffee <- read.csv("./Data/long_data.csv",
                   encoding = "latin1", 
                   stringsAsFactors = FALSE, row.names=NULL) %>% 
  as_data_frame()

# Make sure all variables are of the right data type
coffee <- coffee %>%
  select(relweek, day, transaction_id, house, brand, shop, choice, price,
         ref_price, gain, loss, unchanged,
         brand_loyalty, cust_type, promo_price, promo_units) %>%
  mutate(relweek = as.factor(relweek),
         day = as.factor(day),
         shop = as.factor(shop),
         brand = as.factor(brand),
         cust_type = as.factor(cust_type),
         house = as.character(house)) %>%
  arrange(transaction_id)

# Make GAIN & LOSS variables dummies instead of numeric
coffee <- coffee %>%
  mutate(gain = ifelse(gain>0, 1, gain),
         loss = ifelse(loss<0, 1, loss))

# Define the format of the data for mlogit
# coffee$row <- 1:nrow(coffee)
TM.coffee <- mlogit.data(coffee,
                         choice = "choice",
                         shape = "long",
                         alt.var = "brand",
                         chid.var = "transaction_id",
                         id.var = "house")

colnames(TM.coffee)


# Compute utilities ------------------------------------------------------------

# Simple model allows us to estimate market shares of each brand
# mrkt.share <- mlogit(choice ~ price, data=TM.coffee)
# summary(mrkt.share)


# Adding the variable of promotions to absorb some of the effect exerted 
# on price.
model2a <- mlogit(choice ~ price + promo_price, data=TM.coffee)
summary(model2a)
# 
# model2b <- mlogit(choice ~ price + promo_price + promo_units, data=TM.coffee)
# summary(model2b)


# Time to compute the utility associated to loss and gain.
# model3a <- mlogit(choice ~ price + promo_price + loss, data=TM.coffee)
# summary(model3a)

model3b <- mlogit(choice ~ price + promo_price + loss + gain, data=TM.coffee)
summary(model3b)


# Including proxy variables for consumer heterogeneity -> stat insignificant (!)
# model4a <- mlogit(choice ~ price + promo_price + loss + brand_loyalty, data=TM.coffee)
# summary(model4a)
# 
# model4b <- mlogit(choice ~ price + promo_price + loss + gain + brand_loyalty, data=TM.coffee)
# summary(model4b)


# Reading the results:
# Now price seems to have less of an effect because before it was capturing 
# part of the effect of promotions. 
# Not all parameters are easy to interpret (as in OLS) and we can not compute
# price elasticities from these. However we can compute them by simulating.
# i.e. add 10% to the price and lokk at what happens to the demand.


# Modeling -------------------------------------------------------------------

# Clean up environment --------------------------------------------------------


