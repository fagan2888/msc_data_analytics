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
library(countreg)


# Read parsed data -------------------------------------------------------------
long_coffee <- read.csv("./Data/long_data.csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE) %>% 
  as_data_frame()

long_coffee <- na.omit(long_coffee)
long_coffee <- long_coffee[long_coffee$price > 0, ]

long_coffee <- long_coffee %>%
  select(relweek, day, house, brand, choice, brand_loyalty,
         cust_type, price, promo_price, promo_units, 
         ref_price, gain, loss, unchanged) %>%
  mutate(relweek = as.factor(relweek),
         day = as.factor(day),
         brand = as.factor(brand),
         cust_type = as.factor(cust_type),
         house = as.character(house))

# Quick overview of fields in the dataset
str(long_coffee)
summary(long_coffee)

# Define the format of the data
TM.coffee <- mlogit.data(long_coffee,
                         choice = "choice",
                         shape = "long",
                         alt.levels = "brand",
                         chid.var = "transaction_id",
                         id.var = "house")

str(TM.coffee)
summary(TM.coffee$price)
table(TM.coffee$choice)

# Market share model ----------------------------------------------------------

TM1 <- TM.coffee[TM.coffee$house == '56095', ]
str(TM1)
summary(TM.coffee$brand_loyalty)
mktshare <- mlogit(choice ~ price, data=TM1)

mktshare <- mlogit(choice ~ price, data=TM.coffee)
mktshare <- mlogit(choice ~ price + promo_price + brand_loyalty, data=TM.coffee)
summary(mkt.share)

l<-sapply(TM.coffee, function(x)is.factor(x))
m<-TM.coffee[, names(which(l=="TRUE"))]
ifelse(n<-sapply(m,function(x)length(levels(x)))==1,"DROP","NODROP")

#data.pois <- data.butter[data.butter$choice=='1', ]


model <- mlogit(choice ~ price + display + feature + brand_loyalty + gain + loss, 
                data=TM.coffee)

# Filter and clean data ---------------------------------------------------------

#coffee <- coffee %<% 

  
# Modeling ----------------------------------------------------------------------


