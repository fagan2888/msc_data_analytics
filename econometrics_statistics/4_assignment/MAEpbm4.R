### Maria Athena B. Engesaeth
### CID 01159179


##################################################################################
setwd("/Users/MariaAthena/Dropbox/00 Imperial College/Statistics and Econometrics/Problem Set 4")
##################################################################################
load("meap00_01.RData")
desc


## 1. Data from Michigan Department of Education on students level of 
## proficiency in reading and math


# A. Estimate OLS model and obtain standard errors and robust standard errors.
#
# Estimating: math4 = β0 + β1lunch + β2 log(enroll) + β3 log(exppp) + u
math.model <- lm(formula = math4 ~ lunch + lenroll + lexppp, data)
summary(math.model)
#
# SRF: math4 = 91.93 - 0.45 lunch - 5.40 log(enroll) + 3.52 log(exppp)
# Sample size: 1,692
# R-squared: 0.3729 - i.e. in this sample data, 37.29% of the proportion of the
# students' achieving satisfactory marks in 4th grade math is explained by the 
# variables in this model.
# P-value: 2.2e-16 <<< very small
# We find that unlike expenditure per pupil, neither eligibility for subsidized
# lunch nor school enrollment is statistically significant, and their effects 
# are not practically large.
# se(lunch): 0.01
# se(log(enroll)): 0.94
# se(log(exppp)): 2.10
#
library(sandwich)
library(lmtest)
vcov.robust <- vcovHC(math.model, "HC1")
coeftest(math.model, vcov=vcov.robust)
# robust se(lunch): 0.01
# robust se(log(enroll)): 1.13
# robust se(log(exppp)): 2.35
# As expected the robust standard errors are larger than the OLS standard errors
# as they usually are when the error terms are heteroskedastic.


# B. White test for heteroskedasticity. F test, and conclusion.
#
# We do an F test comparing the regular OLS and the robust OLS model, this allows
# us to conclude if the the error terms
# H0: delta_1 = delta_2 = delta_3 = 0
# H1 != H0
fitted.math <- math.model$fitted.values
bptest(math.model, ~fitted.math+I(fitted.math^2))
# OR
library(car)
linearHypothesis(math.model, c("lunch=0", "lenroll=0", "lexppp=0"),
                 vcov.=vcov.robust, white.adjust="hc1")
qf(0.95, 1691, 1698)
# F-stat: 247.9 >> [1.1]
# P-value: 2.2e-16 <<< small
# Conclusion -> We fail to reject the null hypothesis that the error terms are 
# non heteroskedastic, the squared error terms may have a linear relationship
# to the independant variables.


# C. Weighted Least Square (WLS) Method to predict math proficiency of students.
#
# First we calculate the log of the square of the residuals
aux.y <- log(math.model$residuals^2)
# then we find the fitted values (g(x)) value to weight the model against
aux.model <- lm(aux.y ~ fitted.model$fitted.values + 
                    I(fitted.model$fitted.values^2), data)
#
# We then find the h=exp(g) to weight the OLS model using WLS with weight 1/h
# i.e. each variable is divided by 1/h
h <- exp(aux.model$fitted.values)
math.wls <- lm(math4 ~ lunch + lenroll + lexppp, data = data, weights = 1/h)
summary(math.wls)
#
# We obtain the WLS model:
# SRF.c: math4/h = 52.05 - 0.44 lunch/h - 2.92 log(enroll)/h + 6.47 log(exppp)/h
# R-squared: 0.3393
# P-value: 2.2e-16 << small
# The differences between the coefficients in the OLS and the WLS model are
# not significant. The OLS and WLS parameters are consistent for the same
# population parameters, however, they differ in their asymptotic efficiency 
# (i.e. var is smaller as population size increases).
# We can not compare the R-squared values because the dependent variables are 
# different in the two models.


# D. Obtain the standard errors for WLS that allow misspecification of the 
# variance function. Do these differ much from the usual WLS standard errors?
#
vcov.robust <- vcovHC(math.wls, "HC1")
coeftest(math.wls, vcov=vcov.robust)
# WLS se(lunch): 0.015
# WLS se(log(enroll)): 1.522
# WLS se(log(exppp)): 1.856
# The robust WLS se are slightly more significant for log(enroll) and log(exppp).
# In this regression the variance function is allowed to be misspecified and 
# estimation should in theory be more valid.


# E. For estimating the effect of spending on math4, does OLS or WLS appear to
# be more precise?
#
# Since the parameters are equal in magnitude in both the OLS and WLS functions 
# we can conclude that the functions are not misspecified. 
# From part 1.B we were able to conclude that the error terms are heteroskedastic.
# This however does not allow us to conclude on what causes the heteroskedasticity.
# WLS will be more efficient in its estimation for large samples.
# There are pros and cons to using each method. For WLS we know that the estimates 
# will be unbiased and efficient however we do not know the variances in advance
# and we need to make an estimate of this. An alternative would be to keep the OLS
# estimator for β and look for a valid estimator for its variance, though this might
# cause it to lose efficiency with respect to the WLS estimate.
# 
# WLS β(lexppp) p-value = 0.0002 < OLS β(lexppp) p-value = 0.0931
# The p-value indicating that the lexppp is more statistically significant in the
# WLS model gives us an indication that the WLS model provides a better prediction
# for the effect of spending on math4.



##################################################################################
##################################################################################
load("jtrain.RData")
desc

## 2. Data on companies' scrap rate in relation to grants received.

# A. Regression model given by: log(scrap) = β0 + β1 grant + u
# Reasons why the unobserved factors in u might be correlated with grant?
# It seems intuitive that a company's scrap rate would not rely solely on wether
# or not a grant was received. Other variables are likely to determine this,
# such as the technology the company is using, number of years in activity which
# would impact the company's accumulated knowledge in its industry. Therefor the
# error term which in this model encompasses these variables is likely to be 
# correlated with grants received by a company.


# B. Estimate the regression model using the data for 1988. Interpret.

scrap.88 <- na.omit(subset(data, data$year==1988, select = c(lscrap, grant)))
# OR
also.scrap.88 <- na.omit(data.frame(data$lscrap[data$year==1988], data$grant[data$year==1988]))
colnames(scrap.88) <- c("lscrap", "grant")

scrap.model <- lm(formula = lscrap ~ grant, data = scrap.88)
summary(scrap.model)
# SRF.b: log(scrap) = 0.409 + 0.057 grant + u
# R-squared: 0.0004
# P-value: 0.8895 >> very high
# The high value allows us to conclude that the grant variable is a poor predictor
# for a company's scrap rate in this data set. This is consistent with the
# reasoning from part A.


# C. Adding lagged variable as explanatory variable. Interpret.
# How does it improve the coefficient on grant. Is it statistically significant 
# at the 5% level against the one-sided alternative 
#
newscrap.88 <- na.omit(subset(data, data$year==1988, select = c(lscrap, grant, lscrap_1)))
lagscrap.model <- lm(formula = lscrap ~ grant + lscrap_1, data = newscrap.88)
summary(lagscrap.model)
#
# SRF.c: log(scrap) = 0.021 - 0.254 grant + 0.831 lscrap(87) + u
# R-squared: 0.8728
# P-value: 2.2e-16 << very low
# In this model the parameter associated with the grant variable goes from being
# positive to being negative. The R-squared, i.e. the goodness of fit has 
# improved by alot and so has the P-value of our new model. This indicates this
# regression model provides a better estimate of a grant's effect on a company's
# scrap rate.
#
# To further support this reasoning we complete a T-test at a statistical level 
# of significance of 5%:
# alpha = 5%
# df = 54-2-1 = 51 
# H0: βgrant = 0
# H1: βgrant < 0
# t-statistic = -1.727
# critical value = -1.675
qt(0.05, 51)
# T > c : Hence we we reject the null hypothesis that that grant has no effect
# against the alternative that it has a negative effect


# D. T-test for parameter on log(scrap87). Report the p-value for the test.
#
# alpha = 10%
# df = 54-2-1 = 51 
# H0: β lag.var = 1
# H1: β lag.var != 1
library(car)
linearHypothesis(lagscrap.model, c("lscrap_1=1"))
# F-test = 14.432 for q = 1, df = 51
qf(0.90, df1=52, df2=51) 
# Critical value at 10% = 1.434
# P-value = 0.0004 << very low
# F > c : Hence we we reject the null hypothesis.


# E. Repeat parts (c) and (d), using heteroskedasticity-robust standard errors.
# and briefly discuss any notable differences.
library(sandwich)
library(lmtest)
vcov.robust <- vcovHC(lagscrap.model, "HC1")
coeftest(lagscrap.model, vcov=vcov.robust)
# robust se(grant): 0.146
# robust se(log(lscrap_1)): 0.074

# alpha = 5%
# df = 54-2-1 = 51 
# H0: βgrant = 0
# H1: βgrant < 0
# t-statistic = -1.735
# critical value = -1.675
qt(0.05, 51)
# T-stat < c: thus we reject the null hypothesis that the grant variable
# is not statistically significant at a level of 5%. This is the same result as 
# in 2.C.

qt(0.1, 51)
# Test statistic: (0.83116 - 1) / 0.0735  = - 2.297
# Critical value at 10%: -1.29
# P-value = 0.0256 < low
# T-stat < c : Hence we we reject the null hypothesis as in question 2.D

