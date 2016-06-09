# Inventory Management Under High Uncertainty - Maria Athena B. Engesaeth
# 00_monte_carlo_simulation
#
# Prepare working environment----------------------------------------------------------

# Clean up
rm(list = ls())

library(readr)
library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select


# Load data ----------------------------------------------------------------------------

managers.forecasts <- read_csv('./data/exhibit10.csv')

summary(managers.forecasts)
