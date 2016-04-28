# Research Project - Maria Athena B. Engesaeth
# 02_make_data_long
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
coffee_parsed <- read.csv("./Data/parsed_coffee.csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE) %>%
  as_data_frame()


# Quick overview of fields in the dataset
#str(coffee_parsed)
#summary(coffee_parsed)


# Create dataframe with brand availability --------------------------------------

# Aggregate by what brands were selected at same shop on same day
brand_avail1 <- coffee_parsed %>%
  #select(-house, -brand_loyalty, -cust_type, -last_choice,
  #       -ref_price, gain, loss, unchanged) %>%
  
  mutate(soon_unique = paste(relweek, day, shop_desc_clean, sep=":")) %>%
  group_by(transaction_id, relweek, day, soon_unique,
           house, shop_desc_clean, brand_clean) %>%
  
  # to avoid duplicate error as data has packs over several rows
  summarise(packs = sum(packs)) %>% 
  select(-packs) %>%
  
  mutate(choice = as.numeric(1)) %>%
  
  #summarise(temp_avail_var=paste(brand_clean, collapse=":")) 
  spread(brand_clean, choice) %>%
  gather(brand, choice, 7:12) %>% 
  arrange(transaction_id, house) %>% 
  mutate(brand = as.character(brand)) %>%
  mutate(super_unique = paste(soon_unique, brand, sep=":")) %>%
  mutate(choice = replace(choice, which(is.na(choice)), 0))

# Dataframe containing prices by unique id
price_df <- coffee_parsed %>%
  select(relweek, day, house, shop_desc_clean, brand_clean, price) %>%
  mutate(brand = as.character(brand_clean)) %>%
  mutate(super_unique = paste(relweek, day, shop_desc_clean, brand, sep=":")) %>%
  select(-relweek, -day, -shop_desc_clean, -brand_clean, -brand, -house)


length(unique(price_df$super_unique))
length(unique(brand_avail1$super_unique))

# Join
brand_avail <- merge(brand_avail1, price_df, by="super_unique", all=F, sort=F) 
brand_avail <- full_join(brand_avail1, price_df, by="super_unique")
brand_avail <- rbind(brand_avail1, price_df)

#brand_avail <- merge(cbind(brand_avail1, X= , price_df, by="super_unique", all=T, sort=F) 
merge(cbind(dat1, X=rownames(dat1)), cbind(dat2, variable=rownames(dat2)))

brand_avail <- brand_avail %>%
  select(-soon_unique, -super_unique)

brand_avail <- brand_avail1 %>%
    left_join(price_df, by = c("super_unique"))


# Create data frame with variable to join ----------------------------------------

house_vars <- coffee_parsed %>%
  select(transaction_id, house, brand_loyalty, cust_type,
         last_choice, promo_price, promo_units,
         ref_price, gain, loss, unchanged)

# Joint to create long version incl. all variables -------------------------------

coffee_long <- brand_avail %>% 
  left_join(house_vars, by = c("transaction_id", "house"))

# Clean memory output csv -------------------------------------------------------
rm(coffee_parsed, brand_avail1, brand_avail, price_df, house_vars)
gc(verbose = FALSE)

write_csv(coffee_long, "./Data/long_data.csv")
