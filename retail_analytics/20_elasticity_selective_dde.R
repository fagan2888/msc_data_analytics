# Research Project - Maria Athena B. Engesaeth
# 20_elasticity_selective_dde
#
# Prepare working environment----------------------------------------------------------

library(mlogit)
library(countreg)
# Zero truncated POISSON ("countreg") or conditional Poisson distribution where
# zero is not a possible solution (i.e. the shopper in line to buy does not 
# have 'zero' items in his basket)


# Step 1 - load data -------------------------------------------------------------------
# Read data from .txt
data.butter <- read.table("/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1602 Retail Marketing Analytics/Data Analysis//160301\ Butter/ButterDataTab.txt")

TM.butter <- mlogit.data(data.butter, 
                         choice = "choice", 
                         shape = "long", 
                         alt.var = "brand", 
                         chid.var = "transaction", 
                         id.var = "id")


#mkt.share <- mlogit(choice ~ price, data=TM.coffee)
mkt.share <- mlogit(choice ~ price, data=TM.butter)
summary(mkt.share)

#brand.pref <- mlogit(choice ~ price + promo_price + promo_units, data = TM.coffee)
brand.pref <- mlogit(choice ~ price + display + feature, data = TM.butter)
summary(brand.pref)


# Market share elasticties (elasticities for selective demand) ------------------------

# Price elasticity for Brand Nescafe
#mean(brand.pref$coefficients[5] * brand.pref$probabilities[,1] * 
#       (1 - brand.pref$probabilities[,1])) / mean(brand.pref$probabilities[,1]) / (
#         1/mean(TM.coffee$price[TM.coffee$brand=="Nescafe"]))

# Price elasticity for Brand 1
mean(brand.pref$coefficients[5] * brand.pref$probabilities[,1] * 
       (1 - brand.pref$probabilities[,1])) / mean(brand.pref$probabilities[,1]) / (
         1/mean(TM.butter$price[TM.butter$brand=="1"]))


# SIMULATE price increase/reduction
 # i.e. change the price by 10% and measure the impact on demand.
# This is especially useful with non-linear models (e.g. choice models)
# or when there are lag effects present.

# Simulate a price increase and reduction
#data.sim <- TM.coffee
#data.sim$price_incr <- TM.coffee$price*1.10
#data.sim$price_red <- TM.coffee$price*0.90
#data.sim <- TM.butter
#data.sim$price_incr <- TM.butter$price*1.10
#data.sim$price_red <- TM.butter$price*0.90


# NB------------------------------
# For selective elasticity of demand we simulate the change in price of only one
# brand and measure the impact on the others.
nescafe_incr <- TM.coffee %>%
  filter(brand == "Nescafe") %>%
  mutate(price = price * 1.1) %>%
  bind_rows(TM.coffee %>% filter(brand != "Nescafe"))
# Then can use predict(model,data) but you need to be careful to change only the 
# price of one brand and notice that the model$probabilities already gives you
# the probabilities of each observation under the original data


# Repeat across all brands and obtain the values to build the elasticity matrix



# NB------------------------------


# to denote the new/simulated price: np
# i for increase
# r for reduction
npi_carte <- 
douwe <- 
kenco <- 
nesca <- 
other <- 
super <- 

  
  

# For Philadelphia
newprice_philly <- price_philly*1.10 
par_philly <- final_linear_philly$coefficients

newsales_philly <- par_philly[1] + par_philly[2] * feat_philly + 
  par_philly[3] * disp_philly + par_philly[4] * newprice_philly

mean((newsales_philly-sales_philly)/sales_philly)/.1

# For Private Label
par_pl <- final_linear_pl$coefficients
newprice_pl <- price_pl*1.10

newsales_pl <- par_pl[1] + par_pl[2] * newprice_pl + 
  par_pl[3] * price_philly + par_pl[4] * disp_pl + par_pl[5] * week

mean((newsales_pl-sales_pl)/sales_pl)/.1


