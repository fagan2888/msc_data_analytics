# Demand Forecasting - Maria Athena B. Engesaeth
# 03_forecast_demand
#
# Prepare environment ------------------------------------------------------------
rm(list = ls())

library(readr)
library(magrittr)
library(tidyr)
library(dplyr)
select <- dplyr::select
library(forecast)
library(tseries)


# Load historical lettuce demand by shop -----------------------------------------

hist.demand <- read_csv('./parsed_data/historical_demand_by_shop.csv')

hist.demand <- hist.demand %>% 
  mutate(day = rownames(hist.demand)) %>% 
  select(-date)

# Create timeseries for each row being historical daily demand of lettuce
ninth_46673.ts <- ts(hist.demand$ninth_46673, frequency = 1, start = 1) 
shattuck_4904.ts <- ts(hist.demand$shattuck_4904, frequency = 1, start = 1)
myrtle_12631.ts <- ts(hist.demand$myrtle_12631, frequency = 1, start = 1)
whitney_20974.ts <- ts(hist.demand$whitney_20974, frequency = 1, start = 1)


# Get best fid models for each shop ----------------------------------------------

## CALIFORNIA: ninth_46673
# ARIMA
ninth_46673.A <- Arima(ninth_46673.ts, order=c(2,0,1),  include.drift=TRUE)
ninth_46673.A_F <- forecast.Arima(ninth_46673.A, h=14)

## CALIFORNIA: shattuck_4904
# ARIMA
shattuck_4904.A <- Arima(shattuck_4904.ts, order=c(1,1,1),  include.drift=TRUE)
shattuck_4904.A_f <- forecast.Arima(shattuck_4904.A, h=14)

## NEW YORK: myrtle_12631
# Holt-Winters
myrtle_12631.HW <- HoltWinters(myrtle_12631.ts, gamma=FALSE)
myrtle_12631.HW_f <-forecast.HoltWinters(myrtle_12631.HW, h=14)

## NEW YORK: whitney_20974
# ARIMA
whitney_20974.A <- Arima(whitney_20974.ts, order=c(2,0,1),  include.drift=TRUE)
whitney_20974.A_f <- forecast.Arima(whitney_20974.A, h=14)


# Get 14day forecast for lettuce demand -----------------------------------------

ninth_46673 <- ninth_46673.A_F$mean
shattuck_4904 <- shattuck_4904.A_f$mean
myrtle_12631 <- myrtle_12631.HW_f$mean
whitney_20974 <- whitney_20974.A_f$mean


# Populate data frame to output -------------------------------------------------

forecast_dates <- c('2015-06-16', '2015-06-17', '2015-06-18', '2015-06-19',
                    '2015-06-20', '2015-06-21', '2015-06-22','2015-06-23',
                    '2015-06-24', '2015-06-25', '2015-06-26', '2015-06-27',
                    '2015-06-28', '2015-06-29')

output.df <- data.frame(forecast_dates) %>% 
  mutate(ninth_46673 = ninth_46673, 
         shattuck_4904 = shattuck_4904,
         myrtle_12631 = myrtle_12631,
         whitney_20974 = whitney_20974)

write_csv(output.df, './parsed_data/01159179.csv')

