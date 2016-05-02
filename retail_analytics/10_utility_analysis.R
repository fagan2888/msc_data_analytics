# Research Project - Maria Athena B. Engesaeth
# 10_utility_analysis
#
# Prepare working environment---------------------------------------------------
library(readr)
library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select
library(mlogit)
#library(countreg)

# Clean up
rm(list = ls())

# Load parsed, filtered and cleaned --------------------------------------------

# coffee <- read.csv("./Data/long_mlogit_readable.csv",
coffee <- read.csv("./Data/long_data.csv",
                   encoding = "latin1", 
                   stringsAsFactors = FALSE, row.names=NULL) %>% 
  as_data_frame()

coffee <- coffee %>%
  select(relweek, day, transaction_id, house, brand, shop, choice, price,
         ref_price, gain, loss, unchanged,
         brand_loyalty, cust_type, promo_price, promo_units) %>%
  mutate(relweek = as.factor(relweek),
         day = as.factor(day),
         shop = as.factor(shop),
         brand = as.factor(brand),
         #cust_type = as.factor(cust_type),
         house = as.character(house)) %>%
  arrange(transaction_id)

# Make GAIN & LOSS variables dummies
coffee <- coffee %>%
  mutate(gain = ifelse(gain>0,1,gain),
         loss = ifelse(loss<0,1,loss))

# Define the format of the data for mlogit
coffee$row <- 1:nrow(coffee)
TM.coffee <- mlogit.data(coffee,
                         choice = "choice",
                         shape = "long",
                         alt.var = "brand",
                         chid.var = "transaction_id",
                         id.var = "house")


# Compute utilities ------------------------------------------------------------



# Market share model ---------------------------------------------

mrkt.share1 <- mlogit(choice ~ price, data=TM.coffee)
summary(mrkt.share1)

mrkt.share2 <- mlogit(choice ~ price + promo_price, data=TM.coffee)
mrkt.share2 <- mlogit(choice ~ price + loss + gain, data=TM.coffee)
summary(mrkt.share2)


# 
mrkt.share1 <- mlogit(choice ~ price, data=TM.coffee)


# Reading the results:
# Now price seems to have less of an effect because before it was capturing 
# part of the effect of display and feature; notice that all of the parameters 
# are not as easy to interpret as in linear regression, i.e. we can not compute
# price elasticities from these. However we can compute them by simulating.
# i.e. add 10% to the price and lokk at what happens to the demand.








# XXXXX model ---------------------------------------------

mktshare <- mlogit(choice ~ price + promo_price + brand_loyalty, data=TM.coffee)





model <- mlogit(choice ~ price + display + feature + brand_loyalty + gain + loss, 
                data=TM.coffee)

# Filter and clean data ---------------------------------------------------------

#coffee <- coffee %<% 


# Modeling ----------------------------------------------------------------------


