# Demand Forecasting - Maria Athena B. Engesaeth
# 00_get_data
#
# Prepare working environment----------------------------------------------------------

# Clean up
rm(list = ls())

library(readr)
library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select
library(lubridate)
library(stringr)
library(countreg)
library(DataCombine)
# library(corrplot)


# Load data and set colnames to lower --------------------------------------------------

ingredients <- read.csv('./data/ingredients.csv') %>% 
  setNames(tolower(names(.)))

menu_items <- read.csv('./data/menu_items.csv') %>% 
  setNames(tolower(names(.)))

menuitem <- read.csv('./data/menuitem.csv') %>% 
  setNames(tolower(names(.)))

portion_uom_types <- read.csv('./data/portion_uom_types.csv') %>% 
  setNames(tolower(names(.)))

pos_ordersale <- read.csv('./data/pos_ordersale.csv') %>% 
  setNames(tolower(names(.)))

recipe_ingredient_assignments <- read.csv('./data/recipe_ingredient_assignments.csv') %>% 
  setNames(tolower(names(.)))

recipe_sub_recipe_assignments <- read.csv('./data/recipe_sub_recipe_assignments.csv') %>% 
  setNames(tolower(names(.)))

recipes <- read.csv('./data/recipes.csv') %>% 
  setNames(tolower(names(.)))

store_restaurant <- read.csv('./data/store_restaurant.csv') %>% 
  setNames(tolower(names(.)))

sub_recipe_ingr_assignments <- read.csv('./data/sub_recipe_ingr_assignments.csv') %>% 
  setNames(tolower(names(.)))

sub_recipes <- read.csv('./data/sub_recipes.csv') %>% 
  setNames(tolower(names(.)))

