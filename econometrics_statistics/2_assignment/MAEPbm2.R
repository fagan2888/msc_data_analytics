### Maria Athena B. Engesaeth
### CID 01159179


##################################################################################################
setwd("/Users/MariaAthena/Dropbox/00 Imperial College/Statistics and Econometrics/Problem Set 2")
##################################################################################################


## 1. Data on prices at fast-food resturant by zip code in the US.
load(file="discrim.RData")
desc


# A. Model examining the price of soda in its log form, in terms of the 
# proportion of the population that is black and log of median income

log.modela <- lm(formula = log(psoda) ~ prpblck + lincome, data=data)
summary(log.modela)

# SRFa: log(est_psoda) = -0.7938 + 0.1216 prpblck + 0.0765 lincome + u
# Sample size: 410 - 9 = 401 fast-food resturants
# R-squared: 0.06809 - this means that only 6.81% of the variation of the 
# predicted soda price is explained by the proportion of the population that 
# is black AND the median houshold income.
# It is likely that other variables have a higher impact on the variation of the
# soda price, such as the costs of doing business in the various areas or the 
# population density.
0.1216 * 0.2
# The predicted increase in soda price given the proportion of the population 
# being black increases by 20% is approximately 2.43%


# B. Model examining the price of soda in its log form, in terms of only the 
# variable that is proportion of the population that is black alone.

log.modelb <- lm(formula = log(psoda) ~ prpblck, data=data)
summary(log.modelb)

# SRFb: log(est_psoda) = 0.0331 + 0.0625 prpblck + u
# R-squared: 0.0183 - this means that only 1.83% of the variation of the 
# predicted soda price is explained by the proportion of the population that is 
# black alone. That is less than in the SRFa. The parameter associated with 
# prpblck is lower in SRFb than SRFa. The fact that the value of this parameter 
# changes when introducing new variables signifies that the two variables 
# (prpblck and lincome) are correlated i.e. not independant. Although this 
# breaks with a central assumptions (ZCM). Although we already know this is 
# unlikely to be true with any real world data.

cor(data$lincome, data$prpblck, "na.or.complete")

# In fact when running a quick command we see that the correlation coefficient
# between the two is -0.5, signifying a moderate negative linear correlation.
# A lower βˆprpblck in SRFb in practice means the weighting of the proportion 
# of the population being black weighs less heavily on the price of soda in 
# this regression model. In other words an increase in the prpblck will result 
# in a smaller increase in the predicted price of soda.
# However, the amount the parameters change may not be terribly meaningful and 
# is rather a function of the magnitudes of the variable's correlations.


# C. Model including the proportion of the population in poverty (prppov) to 
# the regression in part A (SRFa).

log.modelc <- lm(formula = log(psoda) ~ prpblck + lincome + prppov, data=data)
summary(log.modelc)

# SRFc: 
# log(est_psoda) = -1.4633 + 0.0728 prpblck + 0.1369 lincome + 0.380 prppov + u
# R-squared: 0.0869 - this means that 8.69% of the variation of the predicted 
# soda price is explained by the proportion of the population that is black, the
# log of the median income and the proportion of the population being poor. 
# That is more than in the SRFa and SRFb, i.e. data on these variables would 
# predict a more accurate price of soda than the two previous SRF.


# D.Find the correlation between log(income) and prppov.

cor(data$lincome, data$prppov, "na.or.complete")

# The correlation coefficient is -0.8385, meaning there is a strong negative 
# linear relationship between the log(median family income) and the proportion 
# of black living in the zipcode.


# E. Evaluate the statement: "Because lincome and prppov are so highly correlated, 
# they have no business being in the same regression."

# The fact that the two variables are so clearly correlated (i.e. not independant)
# makes it true to a certain extent that they should preferably not be put 
# together in a regression model as the conditional mean of the error term can
# no longer be zero (ZCM assumption). Although we already know this is unlikely
# to be true with any real world data. I would argue that one should not be 
# satisfied with running only this ONE regression model when evaluating the 
# relationship between the variables, but instead perform further analysis that 
# could serve as a sanity check for these results.


##################################################################################################
##################################################################################################


## 2. Data on Chief Executive Officers for U.S.corporations
load(file="ceosal1.RData")
desc

# A. Statement of hypothesis for effect of stock market performance on CEO salary.
# H0: beta3_ros = 0
# At a statistical significance, a firm's performance on stock does not effect 
# the CEO's salary.
# H1: beta3_ros > 0
# At a statistical significance, better stock market performance will increases
# the CEO's salary.


# B. Estimate the model log(salary) = β0 + β1 log(sales) + β2roe + β3ros + u

log.model <- lm(formula = lsalary ~ lsales + roe + ros, data = data)
summary(log.model)

# SRF: pred_lsalary = 4.311 + 0.280 lsales + 0.017 roe + 0.0002 ros
# Sample size: 209 companies were survyed
# R-squared: 0.2827 - meaning that 28.27% of the variation in CEOs' salary is 
# explained by the variables lsales (log of sales), roe (return on equity), 
# ros (return on stocks). 
# If a firm's return on stock were to increase by 50 basis points the predicted 
# salary of its CEO would increase by 1%. Which is not economically significant.


# C.Test the null hypothesis at the 10% significance level.
# alpha = 10%
# df = 209-3-1 = 205 (the t-distribution approaches the standard normal 
# distribution)
# H0: beta3_ros = 0
# H1: beta3_ros > 0
# t-statistic = 0.446
# critical value = 1.29
abs(qt(0.10, 205))
# Since t-statistic < critical value, we fail to reject the null hypothesis 
# that a firm's return on stocks does not affect the CEO's salary in our 
# sample data at a level that is statisticly significant.


# D. Should ros be included in a final model explaining CEO compensation?
# p-value in above tests = 2.2e-16 -> very low
# This P value indicates that if the return on stock had no effect, we would 
# obtain the observed difference or more in 2.2e-14% of studies due to random 
# sampling error in THIS DATA. So while it is unlikely that this data would 
# assume a true null hypothesis, we can not with certainty rule out the 
# possibility that our sample data is unusual.
# Although beta3_ros is relatively low and proves to have low economical and 
# statistical significance, we should examine the effect of omitting this 
# variable before doing so in practice. It is likely that ros is correlated 
# with f.eg. the firm's sales numbers and it would thus bias the significance 
# we attribute to that variable should we omit it from the model.

