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
pre_brand_avail <- coffee_parsed %>%
  #select(-house, -brand_loyalty, -cust_type, -last_choice,
  #       -ref_price, gain, loss, unchanged) %>%
  #mutate(soon_unique = paste(relweek, day, shop_desc_clean, sep=":")) %>%
  
  group_by(transaction_id, relweek, day,
           house, shop_desc_clean, brand_clean) %>%
  
  # to avoid duplicate error as data has packs over several rows
  summarise(packs = sum(packs)) %>% 
  select(-packs) %>%
  
  mutate(choice = as.numeric(1)) %>%
  
  #summarise(temp_avail_var=paste(brand_clean, collapse=":")) 
  spread(brand_clean, choice) %>%
  gather(brand, choice, 6:11) %>% 
  arrange(transaction_id, house) %>% 
  rename(shop = shop_desc_clean) %>%
  #mutate(super_unique = paste(soon_unique, brand, sep=":")) %>%
  mutate(choice = replace(choice, which(is.na(choice)), 0)) %>%
  arrange(relweek, day, brand, shop)


# Dataframe containing prices - create average daily prices by shop by brand
price_df <- coffee_parsed %>% 
  group_by(relweek, day, brand_clean, shop_desc_clean) %>% 
  summarise(price = mean(price),
            promo_price = mean(promo_price),
            promo_units = mean(promo_units)) %>% 
  rename(brand = brand_clean) %>%
  rename(shop = shop_desc_clean) %>%
  arrange(relweek, day, brand, shop)


# Total average prices by shop by brand
# Some price fields come out NAs due to missing information.
# Therefor we create a filler data frame with overall averages 
# across the entire year.
tot_avg_prices <- coffee_parsed %>% 
  group_by(shop_desc_clean, brand_clean) %>% 
  summarise(tot_avg_price = mean(price),
            tot_avg_price_promo = mean(promo_price),
            tot_avg_unit_promo = mean(promo_units)) %>% 
  rename(shop = shop_desc_clean) %>%
  rename(brand = brand_clean)


# Join
brand_avail <- pre_brand_avail %>%
  left_join(price_df, by = c("relweek", "day", "brand", "shop")) %>%
  left_join(tot_avg_prices) %>% 
  mutate(price = ifelse(is.na(price), tot_avg_price, price),
         promo_price = ifelse(is.na(promo_price), tot_avg_price_promo, price),
         promo_units = ifelse(is.na(promo_units), tot_avg_unit_promo, price)) %>%
  #mutate(price = rowSums(cbind(price:tot_avg_price), na.rm=TRUE),
  #       promo_price = rowSums(cbind(price:tot_avg_price_promo), na.rm=TRUE),
  #       promo_units = rowSums(cbind(price:tot_avg_unit_promo), na.rm=TRUE)) %>% 
  select(-tot_avg_price, -tot_avg_price_promo, -tot_avg_unit_promo) %>% 
  ungroup()


# Create data frame with variable to join ----------------------------------------

house_vars <- coffee_parsed %>%
  select(transaction_id, house, brand_loyalty, cust_type,
         last_choice, ref_price, gain, loss, unchanged)

# Joint to create long version incl. all variables -------------------------------

coffee_long <- brand_avail %>% 
  left_join(house_vars, by = c("transaction_id", "house"))

# Clean memory output csv -------------------------------------------------------
rm(coffee_parsed, pre_brand_avail, brand_avail, price_df, house_vars)
gc(verbose = FALSE)

write_csv(coffee_long, "./Data/long_data.csv")
