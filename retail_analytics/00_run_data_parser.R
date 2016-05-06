# # Research Project - Maria Athena B. Engesaeth
# 00_parse_data
#
# Prepare working environment -------------------------------------------------

# Clean up
rm(list = ls())

library(readr)
library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select
library(mlogit)
library(countreg)


# Execute Scripts -------------------------------------------------------------

# Output new .csv files in Project Data directory
source("./DataParsers/00_parse_rawdata.R")
source("./DataParsers/01_make_data_wide.R")
source("./DataParsers/02_make_data_long.R")
# source("./DataParsers/03_mlogit_readable_data.R") # NB! Very slow! ~1hr

# Simple summaries ------------------------------------------------------------

# Take out other and super market own
# filter(!grepl('OtherBrands|SupermarketOwn', brand_clean)) %>% 
coffee_parsed <- read.csv("./Data/parsed_coffee.csv", 
                          encoding = "latin1", 
                          stringsAsFactors = FALSE) %>% 
  as_data_frame()


summarise_by_field <- function(data, field) {
  data %>% 
    group_by_(field) %>% 
    summarise(avg_price = mean(price),
              sd_price = sd(price),
              fr_promo = ifelse(promo_price > 0, frequency(promo_price),0))
              #sd_promo = sd(promo_price))
}  

byBrand <- summarise_by_field(coffee_parsed, "brand_clean")
# byShop <- summarise_by_field(TM.coffee, "shop_desc")
# bySubCat <- summarise_by_field(TM.coffee, "sub_cat_name")
# byHouse <- summarise_by_field(TM.coffee, "house")

promo_freq <- coffee_parsed %>% 
  filter(!grepl('0', promo_price)) %>% 
  group_by(brand_clean)

