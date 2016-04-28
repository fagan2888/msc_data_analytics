# Research Project - Maria Athena B. Engesaeth
# 01_parse_rawdata
#
# Prepare working environment---------------------------------------------------

library(readr)
library(magrittr)
library(dplyr)
select <- dplyr::select
library(DescTools)


# Read raw data ----------------------------------------------------------------
coffee <- read.csv("./Data/InstantCoffee (confidential).csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE) %>% 
  as_data_frame()


# make all colnames lower case
colnames(coffee) <- coffee %>% colnames() %>% tolower()

# sort by time (week and day)
coffee <- coffee %>% arrange(relweek, day)

# Quick overview of fields in the dataset
str(coffee)
summary(coffee)


# Filter and clean -------------------------------------------------------------

coffee_clean <- coffee %>% # Take coffee data then
  # Filter it
  filter(shop_desc %in% c("1TESCO", # Only take certain shops
                          "2ASDA", 
                          "3SAINSBURYS", 
                          "4MORRISONS", 
                          "7DICSOUNTERS Aldi", 
                          "7DISCOUNTERS Lidl")
         & # And
           sub_cat_name %in% c("Granules", # Only take certain coffees
                               "Freeze Dried",
                               "Decaf Freeze Dried", 
                               "Micro Ground")) %>% # then...
  mutate(shop_desc_clean = shop_desc %>% # add cleaner shop name
           substring(2) %>% 
           tolower() %>% 
           gsub("discounters ","", .) %>% 
           gsub("aldi|lidl", "discounters", .),
         
         # Add identifier field for discounted purchases
         promo_price = ifelse(grepl("p off", epromdesc), 1, 0),
         promo_units = ifelse(!grepl("p off", epromdesc) & 
                                !grepl("No Promotion", epromdesc), 1, 0),
         
         # Convert certain fields to categorical variables
         year = as.factor(year),
         day = as.factor(day),
         house = as.character(house),
         
         # Add price field
         price = netspend/packs,
         
         # Add identifier field for discounted purchases
         promo_price = ifelse(grepl("p off", epromdesc), 1, 0),
         promo_units = ifelse(!grepl("p off", epromdesc) & 
                                !grepl("No Promotion", epromdesc), 1, 0)
         )


# Create transaction ID
trans_id <- coffee_clean %>% 
  select(relweek, day, house, shop_desc_clean) %>% 
  distinct() %>% 
  mutate(transaction_id = row_number())

# Add back to data
coffee_clean <- coffee_clean %>% left_join(trans_id)


# Clean brands ------------------------------------------------------------------

brand <- coffee_clean %>% 
  group_by(brand_name, total_range_name) %>% 
  tally() %>% 
  rename(sales = n)

# Rationalise brands
brand <- brand %>% 
  mutate(brand_clean = ifelse(sales < 5000, "OtherBrands", brand_name),
         #brand_clean = ifelse(brand_name == "PL_Standard", "Supermarket own", brand_clean),
         #brand_clean = ifelse(brand_name == "PL_Premium", "Supermarket premium", brand_clean),
         #brand_clean = ifelse(brand_name == "PL_Value", "Supermarket value", brand_clean),
         brand_clean = ifelse(grepl("PL_", brand_name), "SupermarketOwn", brand_clean),
         brand_clean = ifelse(grepl("Nescaf", brand_name), "Nescafe", brand_clean),
         brand_clean = gsub("\\(.*\\)", "", brand_clean)) %>% 
  select(-sales)


# Add back to data
coffee_clean <- coffee_clean %>% 
  left_join(brand, by = c("brand_name", "total_range_name")) %>%
  select(-year, -sub_cat_name, -netspend, -brand_name,
         -total_range_name, -epromdesc, -shop_desc)


# Add variable: Reference price -------------------------------------------------

# (i.e. previous price spent)
coffee_clean <- coffee_clean %>%
  group_by(house) %>%
  mutate(ref_price = lag(price, 1))

# Add variables: GAIN and LOSS compared to reference price ----------------------

coffee_clean <- coffee_clean %>%
  #group_by(transaction_id) %>%
  mutate(gain = as.numeric(ifelse(is.na(ref_price-price), NA,
                                  ifelse(ref_price-price > 0, ref_price-price, 0))),
         loss = as.numeric(ifelse(is.na(ref_price-price), NA,
                                 ifelse(ref_price-price < 0, ref_price-price, 0))),
         unchanged = as.numeric(ifelse(is.na(ref_price-price), NA,
                                       ifelse(ref_price-price == 0, ref_price-price, 0))))
  #select(transaction_id, gain, loss)

# Add to data
#coffee_clean <- coffee_clean %>% left_join(gain_loss, by = "transaction_id")


# Add variable: last brand bought -----------------------------------------------

coffee_clean <- coffee_clean %>%
  group_by(house) %>%
  mutate(last_choice = lag(brand_clean, 1))


# Add variable: loyalty variable ------------------------------------------------

#loyalty = 
# Brand loyalty
brand_breakdown  <- coffee_clean %>% 
  group_by(house, brand_clean) %>% 
  summarise(brand_count = n()) %>% 
  group_by(house) %>% 
  summarise(brand_loyalty = Herfindahl(brand_count))

# Join variable on to data
coffee_clean <- coffee_clean %>% left_join(brand_breakdown, by = "house")


# Add variable: user category ---------------------------------------------------

# Use weekly average weekly volume consumed
# Light = 1st quartile
# Medium = 2nd & 3rd quartile
# Heavy = 4th quartile

# Aggregate data
house_summary <- coffee_clean %>% 
  group_by(relweek, house) %>% 
  summarise(visits = n(),
            total_vol = sum(volume)) %>% 
  ungroup() %>% 
  group_by(house) %>% 
  summarise(avg_weekly_vol = mean(total_vol))

# Classify light / medium / heavy users
quartiles <- quantile(house_summary$avg_weekly_vol)
light_vs_heavy <- house_summary %>% 
  mutate(cust_type = ifelse(avg_weekly_vol <= quartiles[2], "light",
                            ifelse(avg_weekly_vol >= quartiles[4], "heavy", 
                                   "medium"))) %>% 
  select(house, cust_type)

# Join variable on to data
coffee_clean <- coffee_clean %>% left_join(light_vs_heavy, by = "house")


# Clean memory output csv -----------------------------------------------------
rm(coffee, trans_id, brand, brand_breakdown, 
   house_summary, light_vs_heavy, quartiles)
gc(verbose = FALSE)

write_csv(coffee_clean, "./Data/parsed_coffee.csv")
