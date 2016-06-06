# Demand Forecasting - Maria Athena B. Engesaeth
# 02_model_estimation
#
# Prepare environment -----------------------------------------------------------

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

# hist.demand_long <- read_csv('./parsed_data/historical_demand_by_shop_long.csv') 

# Create timeseries for each row being historical daily demand of lettuce
ninth_46673.ts <- ts(hist.demand$ninth_46673, frequency = 1, start = 1) 
shattuck_4904.ts <- ts(hist.demand$shattuck_4904, frequency = 1, start = 1)
myrtle_12631.ts <- ts(hist.demand$myrtle_12631, frequency = 1, start = 1)
whitney_20974.ts <- ts(hist.demand$whitney_20974, frequency = 1, start = 1)


# Plot historical lettuce demand by shop -----------------------------------------

plot.ts(ninth_46673.ts)
plot.ts(shattuck_4904.ts)
plot.ts(myrtle_12631.ts)
plot.ts(whitney_20974.ts)


# Forecast lettuce demand for each store ---------------------------------------------
# Recall for Holt-Winters: gamma=False: when there is no seasonality

## CALIFORNIA: ninth_46673

# Holt-Winters
ninth_46673.HW <- HoltWinters(ninth_46673.ts, gamma=FALSE)
ninth_46673.HW_f <-forecast.HoltWinters(ninth_46673.HW)

# ARIMA: autoregressive integrated moving average
# Making the ts stationary for the ARIMA model
ninth_46673.diff <- diff(ninth_46673.ts, differences=1)
auto.arima(ninth_46673.ts, trace=TRUE, ic='aicc')
# Best model: ARIMA(2,0,1) with non-zero mean
ninth_46673.A <- Arima(ninth_46673.ts, order=c(2,0,1),  include.drift=TRUE)
ninth_46673.A_F <- forecast.Arima(ninth_46673.A)

# Determine best fit model
Box.test(ninth_46673.HW_f$residuals, lag=20, type="Ljung-Box")
Box.test(ninth_46673.A$residuals, lag=20, type="Ljung-Box")
# We reject the null that the residuals are independent as p-value is small
# i.e. the correlations in the population from which the sample is taken are 0, 
# so that any observed correlations in the data result from randomness
# i.e. indicating a good model fit.

# Evaluating HW by looking at the residuals. Ideally, mean = 0 and variance = k.
accuracy(ninth_46673.HW_f)
accuracy(ninth_46673.A)
# From looking at the root mean squared errors we see that the it is lower 
# with ARIMA than for HW. Hence ARIMA is preferred.


# Visualise HW
plot.ts(ninth_46673.ts)
plot(ninth_46673.HW_f)
lines(fitted(ninth_46673.HW_f), col="red", lty=2)

# Visualise ARIMA
plot.ts(ninth_46673.ts)
plot(ninth_46673.A_F)
lines(fitted(ninth_46673.A), col="red")



## CALIFORNIA: shattuck_4904

# Holt-Winters
shattuck_4904.HW <- HoltWinters(shattuck_4904.ts, gamma=FALSE)
shattuck_4904.HW_f <-forecast.HoltWinters(shattuck_4904.HW)


# ARIMA: autoregressive integrated moving average
# Making the ts stationary for the ARIMA model
shattuck_4904.diff <- diff(shattuck_4904.ts, differences=1)
auto.arima(shattuck_4904.ts, trace=TRUE, ic='aicc')
# Best model: ARIMA(2,0,1) with non-zero mean
shattuck_4904.A <- Arima(shattuck_4904.ts, order=c(1,1,1),  include.drift=TRUE)
shattuck_4904.A_f <- forecast.Arima(shattuck_4904.A)

# Determine best fit model
Box.test(shattuck_4904.HW_f$residuals, lag=20, type="Ljung-Box")
Box.test(shattuck_4904.A$residuals, lag=20, type="Ljung-Box")
# We reject the null that the residuals are independent as p-value is small
# i.e. the correlations in the population from which the sample is taken are 0, 
# so that any observed correlations in the data result from randomness
# i.e. indicating a good model fit.

# Evaluating HW by looking at the residuals. Ideally, mean = 0 and variance = k.
accuracy(shattuck_4904.HW_f)
accuracy(shattuck_4904.A)
# From looking at the root mean squared errors we see that the it is lower 
# with ARIMA than for HW. Hence ARIMA is preferred.


# Visualise HW
plot.ts(shattuck_4904.ts)
plot(shattuck_4904.HW_f)
lines(fitted(shattuck_4904.HW_f), col="red", lty=2)

# Visualise ARIMA
plot.ts(shattuck_4904.ts)
plot(shattuck_4904.A_f)
lines(fitted(ninth_46673.A), col="red", lty=2)




## CALIFORNIA: myrtle_12631

# Holt-Winters
myrtle_12631.HW <- HoltWinters(myrtle_12631.ts, gamma=FALSE)
myrtle_12631.HW_f <-forecast.HoltWinters(myrtle_12631.HW)

# ARIMA: autoregressive integrated moving average
# Making the ts stationary for the ARIMA model
myrtle_12631.diff <- diff(myrtle_12631.ts, differences=1)
auto.arima(myrtle_12631.ts, trace=TRUE, ic='aicc')
# Best model: ARIMA(2,0,1) with non-zero mean
myrtle_12631.A <- Arima(shattuck_4904.ts, order=c(0,1,1),  include.drift=TRUE)
myrtle_12631.A_f <- forecast.Arima(myrtle_12631.A)

# Determine best fit model
Box.test(myrtle_12631.HW_f$residuals, lag=20, type="Ljung-Box")
Box.test(myrtle_12631.A$residuals, lag=20, type="Ljung-Box")
# We reject the null that the residuals are independent as p-value is small
# i.e. the correlations in the population from which the sample is taken are 0, 
# so that any observed correlations in the data result from randomness
# i.e. indicating a good model fit.

# Evaluating HW by looking at the residuals. Ideally, mean = 0 and variance = k.
accuracy(myrtle_12631.HW_f)
accuracy(myrtle_12631.A)
# From looking at the root mean squared errors we see that the it is higher 
# with ARIMA than for HW. Hence HW is preferred.


# Visualise HW
plot.ts(myrtle_12631.ts)
plot(myrtle_12631.HW_f)
lines(fitted(myrtle_12631.HW_f), col="red", lty=2)

# Visualise ARIMA
plot.ts(myrtle_12631.ts)
plot(myrtle_12631.A_f)
lines(fitted(myrtle_12631.A), col="red", lty=2)



## CALIFORNIA: whitney_20974

# Holt-Winters
whitney_20974.HW <- HoltWinters(whitney_20974.ts, gamma=FALSE)
whitney_20974.HW_f <-forecast.HoltWinters(whitney_20974.HW)

# ARIMA: autoregressive integrated moving average
# Making the ts stationary for the ARIMA model
whitney_20974.diff <- diff(whitney_20974.ts, differences=1)
auto.arima(whitney_20974.ts, trace=TRUE, ic='aicc')
# Best model: ARIMA(2,0,1) with non-zero mean
whitney_20974.A <- Arima(whitney_20974.ts, order=c(2,0,1),  include.drift=TRUE)
whitney_20974.A_f <- forecast.Arima(whitney_20974.A)

# Determine best fit model
Box.test(whitney_20974.HW_f$residuals, lag=20, type="Ljung-Box")
Box.test(whitney_20974.A$residuals, lag=20, type="Ljung-Box")
# We reject the null that the residuals are independent as p-value is small
# i.e. the correlations in the population from which the sample is taken are 0, 
# so that any observed correlations in the data result from randomness
# i.e. indicating a good model fit.

# Evaluating HW by looking at the residuals. Ideally, mean = 0 and variance = k.
accuracy(whitney_20974.HW_f)
accuracy(whitney_20974.A)
# From looking at the root mean squared errors we see that the it is lower 
# with ARIMA than for HW. Hence ARIMA is preferred.


# Visualise HW
plot.ts(whitney_20974.ts)
plot(whitney_20974.HW_f)
lines(fitted(whitney_20974.HW_f), col="red", lty=2)

# Visualise ARIMA
plot.ts(whitney_20974.ts)
plot(whitney_20974.A_f)
lines(fitted(whitney_20974.A), col="red", lty=2)



