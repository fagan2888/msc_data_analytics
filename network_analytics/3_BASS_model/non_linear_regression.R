### Network Analytics, Assignment 3
### Maria Athena B. Engesaeth
### CID 01159179

#http://en.wikipedia.org/wiki/Bass_diffusion_model
#http://book.douban.com/subject/4175572/discussion/45634092/

# BASS Diffusion Model
# 3 parameters:
# total number of people who eventually buy the product: m
# coefficient of innovation: p
# coefficient of imitation: q

#Pred = (p + q * (C/m) )(m - C)
#Error = Pred - Gross

library(readr)

# Read .csv
setwd("/Users/MariaAthena/Desktop")
data <- read_csv("Terminator_3.csv", col_names = TRUE, skip = 0, col_types = NULL)
library(magrittr)

# 'mutate' comes from 'dplyr' and is "add a field to a data frame"
# only for terminator 3 data
data %<>% mutate(WEEKLY_GROSS = WEEKLY_GROSS/1E6, CUMULATIVE_GROSS = CUMULATIVE_GROSS/1E6)


#data <- read_csv("doctor.csv", col_names = TRUE, skip = 0, col_types = NULL)

library(minpack.lm)
library(dplyr)


Gross <- data$WEEKLY_GROSS
#LagCuGross <- lag(data$CUMULATIVE_GROSS)
LagCuGross <- lag(data$CUMULATIVE_GROSS)
LagCuGross[1] <- 0
data[, 'LAGGED_CUGROSS'] <- as.integer(LagCuGross)

#p <- 0.03
#q <- 0.03
#m <- 1000000

Bass.NLS <- nlsLM(formula=Gross ~ (p + q * (LAGGED_CUGROSS / m)) * (m - LAGGED_CUGROSS),
                  start = list(m=1, p=1, q=1), data=data)
summary(Bass.NLS)

# get coefficient
bass_coeff <- coef(Bass.NLS)
m <- bass_coeff[1]
p <- bass_coeff[2]
q <- bass_coeff[3]

m;p;q

# Extract actuals from dataframe
ActGross <- ts(data$WEEKLY_GROSS)

# Create dataframe of predicted values from Bass.NLS
fitted <- predict(Bass.NLS)
fittedts <- ts(fitted)

# Plot the data
ts.plot(ActGross, fittedtsx, col=c('blue', 'red'))
legend('topright', legend=c('Actual', 'Bass Model'), fill=c('blue', 'red'))
title("Actual vs Predicted Boxoffice Numbers 'Terminator 3'")
