
library(mlogit)
library(dplyr)
library(magrittr)
library(readr)


# ----------------------------------------------------------------------------
long_coffee <- read.csv("./Data/long_data.csv", 
                        encoding = "latin1", 
                        stringsAsFactors = FALSE) %>% 
  as_data_frame()

#write_csv(long_coffee, "./Data/test_long_data.csv")
long_coffee <- na.omit(long_coffee)
long_coffee <- long_coffee[long_coffee$price > 0, ]

long_coffee <- long_coffee %>%
  select(relweek, day, transaction_id, house, brand, shop, choice, price,
         ref_price, gain, loss, unchanged,
         brand_loyalty, cust_type, promo_price, promo_units) %>%
  mutate(relweek = as.factor(relweek),
         day = as.factor(day),
         shop = as.factor(shop),
         brand = as.factor(brand),
         #cust_type = as.factor(cust_type),
         house = as.character(house))


# 
lst1 <- split(long_coffee, long_coffee$transaction_id) 
new_df_all <- do.call(rbind, lst1[lapply(lst1, nrow) == 7]) # You can change 6 to other numbers

write_csv(new_df, "./Data/new_df_all.csv")

TM.coffee <- mlogit.data(new_df,
                         choice = "choice",
                         shape = "long",
                         alt.var = "brand",
                         chid.var = "transaction_id",
                         id.var = "house")
  

# ----------------------------------------------------------------------------
# Misc. tests on data
# ----------------------------------------------------------------------------

TM.coffee <- mlogit.data(long_coffee,
                         choice = "choice",
                         shape = "long",
                         alt.var = "brand",
                         chid.var = "transaction_id",
                         id.var = "house")

# Quick overview of fields in the dataset
str(long_coffee)
summary(long_coffee)

model <- mlogit(choice~price, data=TM.coffee)
summary(model)



TM1 <- TM.coffee[TM.coffee$house == '56095', ]
str(TM1)
summary(TM.coffee$brand_loyalty)

mktshare <- mlogit(choice ~ price, data=TM1)



l<-sapply(TM.coffee, function(x)is.factor(x))
m<-TM.coffee[, names(which(l=="TRUE"))]
ifelse(n<-sapply(m,function(x)length(levels(x)))==1,"DROP","NODROP")

# ----------------------------------------------------------------------------
# Butter test
# ----------------------------------------------------------------------------

butter <- read.table("./Data/butter.txt", 
                     encoding = "latin1", 
                     stringsAsFactors = FALSE) %>% 
  as_data_frame()

butter <- butter %>%
  select(transaction, id, panelist, store, week, brand, price, choice)

#write_csv(butter, "./Data/test_long_data.csv")



TM.butter <- mlogit.data(butter,
                         choice = "choice",
                         shape = "long",
                         alt.var = "brand",
                         chid.var = "transaction",
                         id.var = "panelist")

TM.butter <- mlogit.data(data.butter, 
                         choice = "choice", 
                         shape = "long", 
                         alt.var = "brand", 
                         chid.var = "transaction", 
                         id.var = "id")





