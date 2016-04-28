# Research Project - Maria Athena B. Engesaeth
# 01_make_data_wide
#
# Prepare working environment---------------------------------------------------

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
str(coffee_parsed)
summary(coffee_parsed)


# Filter and clean data ---------------------------------------------------------

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
    gather(variable, value, -(relweek:brand_clean)) %>% 
    unite(temp, brand_clean, variable, sep = "_") %>% 
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
           other_brands_share = otherbrands_sales / total_sold,
           supermarket_own_share = supermarketown_sales / total_sold) %>% 
    select(-total_sold)
  
  return(brand_level)
}


# Filter and perform the spread -----------------------------------------------

heavy <- filter_and_widen(coffee_parsed, "heavy")
medium <- filter_and_widen(coffee_parsed, "medium")
light <- filter_and_widen(coffee_parsed, "light")


# Convert missing values to 0
# heavy[is.na(heavy)] <- 0
# light[is.na(light)] <- 0

# heavy <- heavy[complete.cases(heavy), ]

for(i in 1:ncol(heavy)){
  val <- mean(heavy[,i] %>% sapply(as.numeric), na.rm = TRUE)
  heavy[is.na(heavy[,i]), i] <- val
  # print(val)
}

for(i in 1:ncol(medium)){
  val <- mean(medium[,i] %>% sapply(as.numeric), na.rm = TRUE)
  light[is.na(medium[,i]), i] <- val
  # print(val)
}

for(i in 1:ncol(light)){
  val <- mean(light[,i] %>% sapply(as.numeric), na.rm = TRUE)
  light[is.na(light[,i]), i] <- val
  # print(val)
}



# Output csv -------------------------------------------------------------------
write_csv(heavy, "./Data/wide_only_heavy.csv")
write_csv(medium, "./Data/wide_only_medium.csv")
write_csv(light, "./Data/wide_only_light.csv")
