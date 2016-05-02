# Research Project - Maria Athena B. Engesaeth
# 04_simulate_price_data.R
#
# SIMULATE price increase/reduction -------------------------------------------------

# i.e. change the price by 10% and measure the impact on demand.
# This is especially useful with non-linear models (e.g. choice models)
# or when there are lag effects present.

# For selective elasticity of demand we simulate the change in price of only one
# brand and measure the impact on the others.
# Repeat across all brands and obtain the values to build the elasticity matrix
# Carte Noire Douwe Egbert Kenco Nescafe OtherBrands SupermarketOwn

# Simulate Increase of 10% in all brands -------------------------------

# Carte Noire
carte_incr <- TM.coffee %>%
  filter(brand == "Carte Noire") %>%
  mutate(price = price * 1.1) %>%
  bind_rows(TM.coffee %>% filter(brand != "Carte Noire"))

# Douwe
douwe_incr <- TM.coffee %>%
  filter(brand == "Douwe Egbert") %>%
  mutate(price = price * 1.1) %>%
  bind_rows(TM.coffee %>% filter(brand != "Douwe"))

# Nescafe
nescafe_incr <- TM.coffee %>%
  filter(brand == "Nescafe") %>%
  mutate(price = price * 1.1) %>%
  bind_rows(TM.coffee %>% filter(brand != "Nescafe"))

# OtherBrands
douwe_incr <- TM.coffee %>%
  filter(brand == "OtherBrands") %>%
  mutate(price = price * 1.1) %>%
  bind_rows(TM.coffee %>% filter(brand != "OtherBrands"))

# Supermarket own brand
supermarket_incr <- TM.coffee %>%
  filter(brand == "Nescafe") %>%
  mutate(price = price * 1.1) %>%
  bind_rows(TM.coffee %>% filter(brand != "SupermarketOwn"))



# Simulate Reduction of 10% in all brands ------------------------------

# Carte Noire
carte_reduc <- TM.coffee %>%
  filter(brand == "Carte Noire") %>%
  mutate(price = price * .9) %>%
  bind_rows(TM.coffee %>% filter(brand != "Carte Noire"))

# Douwe
douwe_reduc <- TM.coffee %>%
  filter(brand == "Douwe") %>%
  mutate(price = price * 0.9) %>%
  bind_rows(TM.coffee %>% filter(brand != "Douwe"))

# Egbert
douwe_reduc <- TM.coffee %>%
  filter(brand == "Egbert") %>%
  mutate(price = price * 0.9) %>%
  bind_rows(TM.coffee %>% filter(brand != "Egbert"))

# Nescafe
nescafe_reduc <- TM.coffee %>%
  filter(brand == "Nescafe") %>%
  mutate(price = price * 0.9) %>%
  bind_rows(TM.coffee %>% filter(brand != "Nescafe"))

# OtherBrands
douwe_reduc <- TM.coffee %>%
  filter(brand == "OtherBrands") %>%
  mutate(price = price * 0.9) %>%
  bind_rows(TM.coffee %>% filter(brand != "OtherBrands"))

# Supermarket own brand
supermarket_reduc <- TM.coffee %>%
  filter(brand == "SupermarketOwn") %>%
  mutate(price = price * 0.9) %>%
  bind_rows(TM.coffee %>% filter(brand != "SupermarketOwn"))

# ----------------------------------------------------------------------------

