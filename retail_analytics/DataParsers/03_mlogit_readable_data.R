# Research Project - Maria Athena B. Engesaeth
# 03_mlogit_readable_data
#
# Read long form parsed data -------------------------------------------------------
long_coffee <- read.csv("./Data/long_data.csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE, row.names=NULL) %>% 
  as_data_frame()


# Remove NAs
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
         house = as.character(house)) %>%
  arrange(transaction_id)


# Remove aberrant observation causing error in mlogit.data load
#    -> removes rows duplicated by transaction, likely caused
lst1 <- split(long_coffee, long_coffee$transaction_id) 
mlogit_readable_long <- do.call(rbind, lst1[lapply(lst1, nrow) == 6]) # You can change 6 to other numbers

write_csv(mlogit_readable_long, "./Data/long_mlogit_readable.csv")


# Quick overview of fields in the dataset
#str(long_coffee)
#summary(long_coffee)

#str(TM.coffee)
#summary(TM.coffee$price)
#table(TM.coffee$choice)

