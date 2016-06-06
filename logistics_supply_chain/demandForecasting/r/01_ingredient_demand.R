# Demand Forecasting - Maria Athena B. Engesaeth
# 01_lettuce_demand
#
# Get Data and Load Environment -------------------------------------------------------
source('./r/00_get_data.R')


# Get lettuce required for SUB RECIPES in grams ---------------------------------------

lettuce_sub_recipe <- sub_recipes %>% 
  left_join(sub_recipe_ingr_assignments) %>%
  left_join(ingredients) %>%
  left_join(portion_uom_types) %>%
  select(subrecipeid, ingredientid, quantity, ingredientname, portiontypedescription) %>%
  mutate(ingredientname = tolower(ingredientname)) %>% 
  mutate(lettuce = ifelse(grepl('lettuce', ingredientname), quantity, 0)) %>%
  select(subrecipeid, lettuce, portiontypedescription) %>% 
  mutate(lettuce = ifelse(portiontypedescription == "Gram", lettuce, 28.35 * lettuce)) %>% 
  select(subrecipeid, lettuce) %>% 
  group_by(subrecipeid) %>% 
  summarise(lettuce = sum(lettuce)) %>% 
  mutate(lettuce = ifelse(lettuce == 0, NA, lettuce)) %>%
  na.omit()


# Get lettuce required for RECIPES in grams -------------------------------------------

lettuce_recipe <- recipes %>%
  left_join(recipe_ingredient_assignments) %>%
  left_join(ingredients) %>%
  left_join(portion_uom_types) %>%
  select(recipeid, ingredientid, quantity, ingredientname, portiontypedescription) %>%
  mutate(ingredientname = tolower(ingredientname)) %>% 
  mutate(lettuce = ifelse(grepl('lettuce', ingredientname), quantity, 0)) %>%
  select(recipeid, lettuce, portiontypedescription) %>% 
  mutate(lettuce = ifelse(portiontypedescription == "Gram", lettuce, 28.35 * lettuce)) %>% 
  select(recipeid, lettuce) %>% 
  group_by(recipeid) %>% 
  summarise(lettuce = sum(lettuce)) %>% 
  mutate(lettuce = ifelse(lettuce == 0, NA, lettuce)) %>%
  na.omit()


# Get lettuce required in TOTAL for menu items -----------------------------------------

# Connect SUBRECIPE to RECIPE by the associated factor
sub_to_recipe <- recipe_sub_recipe_assignments %>% 
  select(recipeid, subrecipeid, factor) %>% 
  inner_join(lettuce_sub_recipe, copy = TRUE) %>%
  mutate(lettuce_sub = factor * lettuce) %>% 
  select(recipeid, subrecipeid, lettuce_sub)


# Amount of lettuce required in total for each recipe
total_lettuce <- lettuce_recipe %>% 
  full_join(sub_to_recipe, by=c('recipeid'='recipeid')) %>% 
  select(recipeid, subrecipeid, lettuce, lettuce_sub) %>%
  rowwise() %>% 
  mutate(tot_lettuce = sum(lettuce, lettuce_sub, na.rm = TRUE)) %>% 
  select(-lettuce, -lettuce_sub, -subrecipeid)


# Amount of lettuce required in total for each recipe in menu_items
lettuce_menuitem <- menu_items %>% 
  inner_join(total_lettuce)


# Get historical demand of lettuce from past sales ------------------------------------

# Get past lettuce demand from sales/orders in menuitem
lettuce_demand_by_menuitem <- menuitem %>% 
  select(date, md5key_ordersale, id, plu, quantity) %>% 
  inner_join(lettuce_menuitem, by = c("id" = "menuitemid", 
                                           "plu" = "plu")) %>% 
  rowwise() %>% 
  mutate(lettuce = tot_lettuce * quantity) %>% 
  select(date, md5key_ordersale, lettuce) %>% 
  group_by(date, md5key_ordersale) %>% 
  summarise(lettuce_dde = sum(lettuce))


# Get lettuce demand by store
lettuce_demand_by_shop <- pos_ordersale %>% 
  inner_join(lettuce_demand_by_menuitem) %>% 
  select(date, storenumber, lettuce_dde) %>% 
  mutate(storenumber = as.character(storenumber)) %>%
  filter(storenumber %in% c('46673', '4904', '12631', '20974')) %>% 
  mutate(ninth_46673 = ifelse(storenumber=='46673', lettuce_dde, 0),
         shattuck_4904 = ifelse(storenumber=='4904', lettuce_dde, 0),
         myrtle_12631 = ifelse(storenumber=='12631', lettuce_dde, 0),
         whitney_20974 = ifelse(storenumber=='20974', lettuce_dde, 0)) %>% 
  select(-storenumber, -lettuce_dde) %>% 
  group_by(date) %>% 
  summarise(ninth_46673 = sum(ninth_46673),
            shattuck_4904 = sum(shattuck_4904),
            myrtle_12631 = sum(myrtle_12631),
            whitney_20974 = sum(whitney_20974))

  
# Output parsed data ------------------------------------------------------------------

rm(list= ls()[!(ls() %in% c('lettuce_demand_by_shop'))])

# Output new .csv files in Project Data directory
write_csv(lettuce_demand_by_shop, './parsed_data/historical_demand_by_shop.csv')
