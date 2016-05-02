# # Research Project - Maria Athena B. Engesaeth
# 00_parse_data
#
# Prepare working environment -------------------------------------------------

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
source("./DataParsers/03_mlogit_readable_data.R") # NB! Very slow! ~1hr
