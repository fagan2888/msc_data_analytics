# Research Project - Maria Athena B. Engesaeth
# 02_make_data_long
#
# Read parsed data -------------------------------------------------------------
coffee_parsed <- read.csv("./Data/parsed_coffee.csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE, row.names=NULL) %>%
  as_data_frame()


# Quick overview of fields in the dataset
#str(coffee_parsed)
#summary(coffee_parsed)


# Create dataframe with brand availability --------------------------------------

coffee_parsed$row <- 1:nrow(coffee_parsed)

# Aggregate by what brands were selected at same shop on same day
pre_brand_avail <- coffee_parsed %>%
  select(-volume, -packs, -brand_loyalty, -cust_type,
         -last_choice, -ref_price, -gain, -loss, -unchanged) %>%
  group_by(relweek, day, house, transaction_id,
           shop_desc_clean, brand_clean) %>%
  rename(shop = shop_desc_clean) %>%
  
  #summarise(packs = sum(packs)) %>% 
  #select(-packs) %>%
  
  mutate(choice = as.numeric(1)) %>%
  
  #summarise(temp_avail_var=paste(brand_clean, collapse=":")) 
  spread(brand_clean, choice) %>%
  gather(brand, choice, 10:15) %>% 
  mutate(price = ifelse(is.na(choice), NA, price)) %>%
  arrange(transaction_id, house) %>% 

  mutate(choice = replace(choice, which(is.na(choice)), 0)) %>%
  arrange(relweek, day, transaction_id, brand, shop)


# Dataframe containing prices - create average daily prices by shop by brand
price_df <- coffee_parsed %>% 
  group_by(relweek, day, brand_clean, shop_desc_clean) %>% 
  summarise(avg_price =  mean(price),
            avg_promo_price = mean(promo_price),
            avg_promo_units = mean(promo_units)) %>%
  mutate(avg_promo_price = ifelse(avg_promo_price>0.4, 1, 0),
         avg_promo_units = ifelse(avg_promo_units>0.4, 1, 0)) %>% 
  rename(brand = brand_clean) %>%
  rename(shop = shop_desc_clean) %>%
  arrange(relweek, day, brand, shop)


# Join brand availability data frame and prices data frames
brand_avail <- pre_brand_avail %>%
  left_join(price_df, by = c("relweek", "day", "shop", "brand")) %>%
  mutate(price = ifelse(is.na(price), avg_price, price),
         promo_price = ifelse(is.na(promo_price), avg_promo_price, 0),
         promo_units = ifelse(is.na(promo_units), avg_promo_units, 0)) %>%
  #left_join(tot_avg_prices) %>%
  #mutate(price = rowSums(cbind(price:tot_avg_price), na.rm=TRUE),
  #       promo_price = rowSums(cbind(price:tot_avg_price_promo), na.rm=TRUE),
  #       promo_units = rowSums(cbind(price:tot_avg_unit_promo), na.rm=TRUE)) %>% 
  select(-avg_price, -avg_promo_price, -avg_promo_units) %>% 
  ungroup()

#table(is.na(brand_avail$price))
brand_avail <- na.omit(brand_avail)


# Create data frame with variable to join ----------------------------------------

house_vars <- coffee_parsed %>%
  select(relweek, day, transaction_id, house, brand_loyalty, cust_type,
         last_choice, ref_price, gain, loss, unchanged)

house_vars <- na.omit(house_vars)

# Joint to create long version incl. all variables -------------------------------

coffee_long <- brand_avail %>% 
  left_join(house_vars, by = c("relweek", "day", "transaction_id", "house"))

coffee_long <- na.omit(coffee_long)

# Clean memory output csv -------------------------------------------------------
rm(coffee_parsed, pre_brand_avail, brand_avail, price_df, house_vars)
gc(verbose = FALSE)

write_csv(coffee_long, "./Data/long_data.csv")
