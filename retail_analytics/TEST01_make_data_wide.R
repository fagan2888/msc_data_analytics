# Research Project - Maria Athena B. Engesaeth
# 02_model_analysis
#
# Prepare working environment---------------------------------------------------

library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select
library(mlogit)
library(countreg)


# Read parsed data -------------------------------------------------------------
coffee <- read.csv("./Data/parsed_coffee.csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE) %>% 
  as_data_frame()


# Quick overview of fields in the dataset
str(coffee)
summary(coffee)


# Filter and clean data ---------------------------------------------------------

# dt %.% group_by(a) %.% mutate(b = ifelse(is.na(b), mean(b, na.rm = T), b))

test_heavy <- coffee %>% 
  
  filter(cust_type == 'heavy') %>% 
  group_by(transaction_id, brand_clean) %>% 
  summarise(sales = sum(packs),
            price = mean(price),
            promo_sales_price = sum(promo_price),
            promo_sales_units = sum(promo_units)) %>% 
  mutate(promo_cost = promo_sales_price/sales,
         promo_units = promo_sales_units/sales) %>% 
  select(-promo_sales_price, -promo_sales_units) %>% 
  gather(variable, value, -(transaction_id:brand_clean)) %>% 
  unite(temp, brand_clean, variable, sep = "_") %>% 
  spread(temp, value) %>% 
  ungroup()

colnames(test_heavy) <- colnames(test_heavy) %>% gsub(" ", "_", .) %>% tolower()



jims <- coffee %>% 
    # Filter and widen at brand level
    filter(cust_type == 'heavy') %>% 
    group_by(relweek, brand_clean) %>% 
    summarise(sales = sum(packs),
              price = mean(price),
              promo_sales_price = sum(promo_price),
              promo_sales_units = sum(promo_units)) %>% 
    mutate(promo_cost = promo_sales_price/sales,
           promo_units = promo_sales_units/sales) %>% 
    select(-promo_sales_price, -promo_sales_units) %>% 
    gather(variable, value, -(relweek:brand_clean)) %>% 
    #unite(temp, brand_clean, variable, sep = "_") %>% 
    spread(temp, value) %>% 
    ungroup()
    
    colnames(brand_level) <- colnames(brand_level) %>% gsub(" ", "_", .) %>% tolower()
    
    # Calculate total sales
    total_sales <- data %>% 
      filter(cust_type == cust_status) %>% 
      group_by(relweek) %>% 
      summarise(total_sold = sum(packs))
    
    # Join together
    overall <- left_join(brand_level, total_sales)
    
    # Create brand shares
    overall <- overall %>% 
      mutate(carte_noire_share = carte_noire_sales / total_sold,
             douwe_egbert_share = douwe_egbert_sales / total_sold,
             kenco_share = kenco_sales / total_sold,
             nescafe_share = nescafe_sales / total_sold,
             other_brands_share = other_brands_sales / total_sold,
             supermarket_own_share = supermarket_own_sales / total_sold) %>% 
      select(-total_sold)
    
    return(brand_level)
  }
  

# Filter and spread
heavy <- filter_and_widen(coffee, "heavy")
  
  












# Step 0 - prepare environment -------------------------------------------------
# In-line function definition used in this script only
# This function takes the coffee data, filters to just one customer type (e.g.
# heavy or light), aggregates to a weekly level and then spreads the data
# in to a wide form suitable for modelling
filter_and_widen <- function(data, cust_status = 0) {
  # Filter and widen at brand level
  brand_level <- data %>% 
    filter(cust_type == cust_status) %>% 
    group_by(relweek, brand_clean) %>% 
    summarise(sales = sum(packs),
              price = mean(price),
              promo_sales_price = sum(promo_price),
              promo_sales_units = sum(promo_units)) %>% 
    mutate(promo_cost = promo_sales_price/sales,
           promo_units = promo_sales_units/sales) %>% 
    select(-promo_sales_price, -promo_sales_units) %>% 
    #gather(variable, value, -(relweek:brand_clean)) %>% 
    #unite(temp, brand_clean, variable, sep = "_") %>% 
    spread(temp, value) %>% 
    ungroup()
  
  colnames(brand_level) <- colnames(brand_level) %>% gsub(" ", "_", .) %>% tolower()
  
  # Calculate total sales
  total_sales <- data %>% 
    filter(cust_type == cust_status) %>% 
    group_by(relweek) %>% 
    summarise(total_sold = sum(packs))
  
  # Join together
  overall <- left_join(brand_level, total_sales)
  
  # Create brand shares
  overall <- overall %>% 
    mutate(carte_noire_share = carte_noire_sales / total_sold,
           douwe_egbert_share = douwe_egbert_sales / total_sold,
           kenco_share = kenco_sales / total_sold,
           nescafe_share = nescafe_sales / total_sold,
           other_brands_share = other_brands_sales / total_sold,
           supermarket_own_share = supermarket_own_sales / total_sold) %>% 
    select(-total_sold)
  
  return(brand_level)
}

# Step 1 - perform the spread --------------------------------------------------
# Filter and spread
heavy <- filter_and_widen(coffee, "heavy")








# Clean memory output csv -----------------------------------------------------
rm(coffee, trans_id, brand, gain_loss, last_choice, 
   brand_breakdown, house_summary, light_vs_heavy, quartiles)
gc(verbose = FALSE)

write_csv(coffee_clean, "./Data/parsed_coffee.csv")
