# Research Project - Maria Athena B. Engesaeth
# 01_make_data_wide
#
# Read parsed data -------------------------------------------------------------
coffee_parsed <- read.csv("./Data/parsed_coffee.csv", 
                   encoding = "latin1", 
                   stringsAsFactors = FALSE) %>% 
  as_data_frame()


# Quick overview of fields in the dataset
#str(coffee_parsed)
#summary(coffee_parsed)


# Filter and clean data ---------------------------------------------------------
coffee_clean <- coffee_clean %>%
  group_by(house) %>%
  mutate(ref_price = lag(price, 1))
# In-line function definition used in this script only
# This function takes the coffee data, filters to just one customer type (e.g.
# heavy or light), aggregates to a daily level and then spreads the data
# in to a wide form suitable for modelling
filter_and_widen <- function(data, cust_status = 0) {
  # Filter and widen at brand level
  brand_level <- data %>% 
    filter(cust_type == cust_status) %>% 
    group_by(relweek, day, brand_clean) %>% 
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
    group_by(relweek, day) %>% 
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
#medium <- filter_and_widen(coffee_parsed, "medium")
light <- filter_and_widen(coffee_parsed, "light")
everyone <- filter_and_widen(coffee_parsed, c("light", "heavy"))

# Create dummies for GAIN/LOSS ------------------------------------------------
heavy <- heavy %>%
  mutate(carte_noire_cons_loss = ifelse(lag(carte_noire_price, 1) > carte_noire_price, 0, 1),
         douwe_egbert_cons_loss = ifelse(lag(douwe_egbert_price, 1) > douwe_egbert_price, 0, 1),
         kenco_cons_loss = ifelse(lag(kenco_price, 1) > kenco_price, 0, 1),
         nescafe_cons_loss = ifelse(lag(nescafe_price, 1) > nescafe_price, 0, 1),
         other_brands_cons_loss = ifelse(lag(otherbrands_price, 1) > otherbrands_price, 0, 1),
         supermarket_own_cons_loss = ifelse(lag(supermarketown_price, 1) > supermarketown_price, 0, 1))

light <- light %>%
  mutate(carte_noire_cons_loss = ifelse(lag(carte_noire_price, 1) > carte_noire_price, 0, 1),
         douwe_egbert_cons_loss = ifelse(lag(douwe_egbert_price, 1) > douwe_egbert_price, 0, 1),
         kenco_cons_loss = ifelse(lag(kenco_price, 1) > kenco_price, 0, 1),
         nescafe_cons_loss = ifelse(lag(nescafe_price, 1) > nescafe_price, 0, 1),
         other_brands_cons_loss = ifelse(lag(otherbrands_price, 1) > otherbrands_price, 0, 1),
         supermarket_own_cons_loss = ifelse(lag(supermarketown_price, 1) > supermarketown_price, 0, 1))

everyone <- everyone %>%
  mutate(carte_noire_cons_loss = ifelse(lag(carte_noire_price, 1) > carte_noire_price, 0, 1),
         douwe_egbert_cons_loss = ifelse(lag(douwe_egbert_price, 1) > douwe_egbert_price, 0, 1),
         kenco_cons_loss = ifelse(lag(kenco_price, 1) > kenco_price, 0, 1),
         nescafe_cons_loss = ifelse(lag(nescafe_price, 1) > nescafe_price, 0, 1),
         other_brands_cons_loss = ifelse(lag(otherbrands_price, 1) > otherbrands_price, 0, 1),
         supermarket_own_cons_loss = ifelse(lag(supermarketown_price, 1) > supermarketown_price, 0, 1))

# Clean up -------------------------------------------------------------------

# Convert missing values to 0
# heavy[is.na(heavy)] <- 0
# light[is.na(light)] <- 0

# heavy <- heavy[complete.cases(heavy), ]

for(i in 1:ncol(heavy)){
  val <- mean(heavy[,i] %>% sapply(as.numeric), na.rm = TRUE)
  heavy[is.na(heavy[,i]), i] <- val
  # print(val)
}

# for(i in 1:ncol(medium)){
#   val <- mean(medium[,i] %>% sapply(as.numeric), na.rm = TRUE)
#   light[is.na(medium[,i]), i] <- val
#   # print(val)
# }

for(i in 1:ncol(light)){
  val <- mean(light[,i] %>% sapply(as.numeric), na.rm = TRUE)
  light[is.na(light[,i]), i] <- val
  # print(val)
}



# Output csv -------------------------------------------------------------------
write_csv(heavy, "./Data/wide_only_heavy.csv")
#write_csv(medium, "./Data/wide_only_medium.csv")
write_csv(light, "./Data/wide_only_light.csv")
write_csv(everyone, "./Data/wide_everyone.csv")

