# Research Project - Maria Athena B. Engesaeth
# 02_make_data_long
#
# Read parsed data -------------------------------------------------------------
coffee_parsed <- read.csv("./Data/parsed_coffee.csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE, row.names=NULL) %>%
  # Take out other and super market own
  filter(!grepl('OtherBrands|SupermarketOwn', brand_clean)) %>% 
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
  gather(brand, choice, 10:13) %>% 
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
  mutate(avg_promo_price = ifelse(avg_promo_price < 0.25*avg_price, 1, 0),
         avg_promo_units = ifelse(avg_promo_units < 0.5*avg_price, 1, 0)) %>% 
  rename(brand = brand_clean) %>%
  rename(shop = shop_desc_clean) %>%
  arrange(relweek, day, brand, shop)


# Remove duplicate lines resulting from unit promotions --------------------------

pre_brand_avail <- pre_brand_avail %>% 
  unique() %>% 
  group_by(relweek, day, transaction_id, house, shop, brand) %>% 
  summarise(choice = first(choice),
            price = mean(price))

# Sanity Checks
# length(unique(brand_avail$transaction_id))
# sum(brand_avail$choice)
# length(unique(coffee_long$transaction_id))
# sum(coffee_long$choice)

# Join brand availability data frame and prices data frames -----------------------
brand_avail <- pre_brand_avail %>%
  left_join(price_df, by = c("relweek", "day", "shop", "brand")) %>%
  mutate(price = ifelse(is.na(price), avg_price, price),
         promo_price = ifelse(is.na(avg_promo_price), 0, avg_promo_price),
         promo_units = ifelse(is.na(avg_promo_price), 0, avg_promo_units)) %>%
  #left_join(tot_avg_prices) %>%
  #mutate(price = rowSums(cbind(price:tot_avg_price), na.rm=TRUE),
  #       promo_price = rowSums(cbind(price:tot_avg_price_promo), na.rm=TRUE),
  #       promo_units = rowSums(cbind(price:tot_avg_unit_promo), na.rm=TRUE)) %>% 
  select(-avg_price, -avg_promo_price, -avg_promo_units) %>% 
  na.omit() %>%
  ungroup()

#table(is.na(brand_avail$price))


# Create data frame with variable to join ----------------------------------------

house_vars <- coffee_parsed %>%
  select(relweek, day, transaction_id, house, brand_loyalty, cust_type,
         last_choice) %>% 
  group_by(relweek, day, transaction_id, house) %>% 
  summarise(brand_loyalty = first(brand_loyalty), 
            cust_type = first(cust_type)) %>% 
  na.omit()


# Joint to create long version incl. all variables -------------------------------

coffee_long <- brand_avail %>% 
  left_join(house_vars, by = c("relweek", "day", "transaction_id", "house")) %>% 
  # Add variable: Reference price
  mutate(ref_price = lag(price, 1)) %>% 
  # Add variables: GAIN and LOSS compared to reference price
  mutate(gain = as.numeric(ifelse(is.na(ref_price-price), NA,
                                  ifelse(ref_price-price > 0, ref_price-price, 0))),
         loss = as.numeric(ifelse(is.na(ref_price-price), NA,
                                  ifelse(ref_price-price < 0, ref_price-price, 0))),
         unchanged = as.numeric(ifelse(is.na(ref_price-price), NA,
                                       ifelse(ref_price-price == 0, ref_price-price, 0)))) %>% 
  na.omit()
  

# Clean memory output csv -------------------------------------------------------
rm(coffee_parsed, pre_brand_avail, brand_avail, price_df, house_vars)
gc(verbose = FALSE)

write_csv(coffee_long, "./Data/long_data.csv")
