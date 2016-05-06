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


# Add LOSS dummies for each brand, i.e. if price at t > at t-1 and a price increase
# has taken place, then _loss var = 1 .
# This will allow us to consider the possibility of assymetric demand price sensitivities.
gain_loss_dumm <- function(data) {
  # Filter and widen at brand level
  add_dummies <- data %>% 
    mutate(carte_noire_cons_loss = ifelse(is.na(carte_noire_price), 0,
                                          ifelse(lag(carte_noire_price, 7) > carte_noire_price, 0, 1)),
           douwe_egbert_cons_loss = ifelse(is.na(douwe_egbert_price), 0,
                                           ifelse(lag(douwe_egbert_price, 7) > douwe_egbert_price, 0, 1)),
           kenco_cons_loss = ifelse(is.na(kenco_price), 0,
                                    ifelse(lag(kenco_price, 7) > kenco_price, 0, 1)),
           nescafe_cons_loss = ifelse(is.na(nescafe_price), 0,
                                      ifelse(lag(nescafe_price, 7) > nescafe_price, 0, 1)),
           other_brands_cons_loss = ifelse(is.na(otherbrands_price), 0,
                                           ifelse(lag(otherbrands_price, 7) > otherbrands_price, 0, 1)),
           supermarket_own_cons_loss = ifelse(is.na(supermarketown_price), 0,
                                              ifelse(lag(supermarketown_price, 7) > supermarketown_price, 0, 1))) %>%
    # Convert missing values to 0
    mutate(carte_noire_cons_loss = replace(carte_noire_cons_loss, which(is.na(carte_noire_cons_loss)), 0),
           douwe_egbert_cons_loss = replace(douwe_egbert_cons_loss, which(is.na(carte_noire_cons_loss)), 0),
           kenco_cons_loss = replace(kenco_cons_loss, which(is.na(carte_noire_cons_loss)), 0),
           nescafe_cons_loss = replace(nescafe_cons_loss, which(is.na(carte_noire_cons_loss)), 0),
           other_brands_cons_loss = replace(other_brands_cons_loss, which(is.na(carte_noire_cons_loss)), 0),
           supermarket_own_cons_loss = replace(supermarket_own_cons_loss, which(is.na(carte_noire_cons_loss)), 0))
}




# Filter and perform the spread -----------------------------------------------

heavy <- filter_and_widen(coffee_parsed, "heavy")
#medium <- filter_and_widen(coffee_parsed, "medium")
light <- filter_and_widen(coffee_parsed, "light")
everyone <- filter_and_widen(coffee_parsed, c("light", "heavy"))

# Create dummies for GAIN/LOSS ------------------------------------------------

heavy <- gain_loss_dumm(heavy)
light <- gain_loss_dumm(light)
everyone <- gain_loss_dumm(everyone)

# Clean up -------------------------------------------------------------------


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

