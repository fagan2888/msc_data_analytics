### Maria Athena B. Engesaeth
### CID 01159179


##################################################################################
setwd("/Users/MariaAthena/Dropbox/00 Imperial College/Statistics and Econometrics/Problem Set 3")
##################################################################################


## 1. Designing an experiment/survey to collect data on wages, education, 
# experience, and gender and marijuana usage. The original question is:
# "On how many separate occasions last month did you smoke marijuana?"


# A. Equation that would allow us to estimate the effects of marijuana usage on
# wage, while controlling for other factors.
# Then %beta_1 is the approximate change in wage when marijuana usage increases
# with one unit per month. Where marij = usage per month.
# pred_log(wage) = beta_0 + beta_1 * marij + beta_2 * educ + beta_3 * exper + u
fictional.data <- load("MarijSurvey.RData")
lm(formula = log(wage) ~ marij + educ + exper, data = fictional.data)


# B. Equation that would allow us to test whether marijuana usage has different 
# effects on wages for men and women.
#
# In the data we introduce a dummy variable that will allow us to tag the data
# points from subjects: 0 for those associating as being male and 1 for female. 
# We re-write the formula from (A) as follows:
# pred_log(wage) = beta_0 + delta_1 * female + delta_2 * female.usage + 
#                   beta_1 * marij + beta_2 * edu + beta_3 * exper + u

lm(formula = log(wage) ~ female + marij + educ + exper + marij:female,
                data = fictional.data)

# We only need delta_1 in the model and we treat the result from the male sub
# group as the base group. By isolating each subgroup we can then compare the 
# female group against the male group. Graphically the difference will be seen 
# as a shift in the regression line.
# We can consequently test if these new variables have an effect on our model
# by posing a null hypothesis and testing it at a statistically significant 
# level at a given critical value of a t-test. The null hypothesis is interpreted
# as: there is no differences in the effects of marijuana usage by gender.
# H0: delta_2 = 0
# H1: delta_2 != 0


# C. Equation that would allow us to measure marijuana usage by creating categories.
#
# In the data we create a set of dummy variables that will allow us to tag the 
# data points as follows:
# We first set the base group to do our comparison against : n.marij = nonuser
# l.marij = light user (1 to 5 times per month) 
# m.marij = moderate user (6 to 10 times per month) 
# h.marij = heavy user (more than 10 times per month).
#
# We re-write the formula from (A) as follows:
# log(wage) = beta_0 + delta_1 * l.marij + delta_2 * m.marij + delta_3 * h.marij +
#               beta_2 * edu + beta_3 + edu^2 + beta_4 * exper + 
#               beta_5 * exper^2 + u
#
# I would include an analysis of the regression including the level of
# education and experience in quadratic forms as these are variables that after
# a certain point would have the inverse effect on wage. We should thus examine
# up until what point the effect is positive/negative and then inverts.

fitted.wage <- lm(formula = log(wage) ~ l.marij +
                      m.marij + h.marij + educ + educ.sq + exper + 
                      exper.sq, data = fictional.data)
summary(fitted.wage)


# D. Using equation (C), explain how to test H0: marijuana usage has no effect on wage.
# We would compare the equation from (A) as being the model with no restriction 
# to that in (C) as being the model with restrictions introduced. We can 
# consequently test if these new variables have an effect on our model.
# H0: delta_1 = delta_2 = delta_3 = 0
# H1: !H0
# Under H0 none of the explanatory variables has an effect on wages and
# R-squared is zero.
# In order to conclude we form an F statistic to test exclusion restrictions.
# Knowing the sample size (n) and the number of restrictions (3) and the degrees 
# of freedom for the unrestricted model (n-k-1) we obtain the critical value (c)
# for the F-test: F3,n-7. We then reject H0 if F > c 
library(car)
linearHypothesis(fitted.wage, "H0")


# E. Problems with drawing causal inference from survey data on Wage~MarijU
# Surveys determine self reporting on usage of a substance that is illegal in 
# the UK and the surveyed people would not have any interest in either not being
# truthful in their reportings or chosing not to participate all together. A 
# possible fix to this issue could be polling in places where Marijuana has been
# legalized such as certain states in the US or in the Netherlands.
# Furthermore there are a number of other factors that might effect marijuana
# usage that that would bias our interpretation of the effect of marijuana
# usage on wage. As an example some people are susciptible to addiction more 
# than others, this can be a genetical trait.
# Other issues include the validity of the ZCM assumption that rarely hold with
# real life data.


##################################################################################
##################################################################################


## 2. Data on the salary of NBA player in the US.
load(file="nbasal.RData")
desc

# A. Estimate the model for points scored by an NBA player by position while 
# also controlling for level of experience. The CENTER position will be the base
# group: [points = β0 + δ1 * guard + δ2 * forward + exper + exper^2 + u]

model <- lm(formula = points ~ guard + forward + exper + expersq, data)
summary(model)

# SRFa: est_points = 4.76 + 2.31 * guard +
#                    1.54 * forward + 1.28 exper - 0.07 expersq
# Sample size = 269 observations
# R-squared = 0.0908 - i.e. 9.08% of the variation in point scored by and NBA 
# player is explained by the variables included in this model.


# B. Holding experience fixed, compare points scored by the guard position with
# the center.
# est_points = 4.76 + 2.31*(guard=(0,1)) + 1.28 exper - 0.072 expersq
# beta_0_center = 4.76
# beta_0_guard = 4.76 + 2.31 = 7.07
# With this regression model the guard scores more points than center when keeping
# all else constant. From the t-value we conclude that this is statistically 
# significant at a level of 5%
# beta_guard / SE_guard = t_value = 2.314 -> which 


# C. Adding players' marital status to the SRF with position and experience fixed.

model.marr <- lm(formula = points ~ marr + guard + forward + exper + expersq, data)
summary(model.marr)

# SRFc: est_points = 4.70 + 0.58 * marr + 2.29 * guard + 1.54 * forward +
#                    1.23 exper - 0.07 expersq
# Sample size = 269 observations
# R-squared = 0.0931 - i.e. 9.31% of the variation in point scored by and NBA 
# player is explained by the variables included in this model.
# The p-value (0.43) does not let us conclude that the marital status of a
# player has statistical significance to his/her ability to score more points
# per game.


# D. Adding interactions of marital status with experience variables.

model.inter <- lm(formula = points ~ marr + guard + forward + exper + expersq +
                      exper:marr + expersq:marr, data)
summary(model.inter)

# SRFd: est_points = 5.81 - 2.53 * marr + 2.25 * guard + 1.69 * forward +
#                    0.70 exper - 0.03 expersq + 1.28 * marr*exper -
#                    0.09 * marr*exper
# Sample size = 269 observations
# R-squared = 0.1058 - i.e. 10.58% of the variation in point scored by an NBA 
# player is explained by the variables included in this model.
#
# In order to conclude whether there is strong evidence that marital status
# affects points per game by an NBA player we pose the below hypothesis and run
# an F test.
# H0: delta_0 = delta_1 = delta_2 = 0
# H1: !0
library(car)
linearHypothesis(model.inter, c("marr=0", "marr:exper=0", "marr:expersq=0"))
# F-test = 1.44 for q = 3 and df = 261
# c at 5% level of significance = 2.60
# P-value = 0.23 
# F < c : Hence we we fail to reject the null hypothesis that marital status
#  has no significant effect on the point scoring of an NBA player.


# E. Estimate the model from part (c) but use assists per game as the dependent 
# variable. Are there any notable differences from part (c)? Discuss.

model.assist <- lm(formula = assists ~ marr + guard + forward + exper + expersq, data)
summary(model.assist)

# SRFe: est_assist = -0.22 - 0.32 * marr + 2.49 * guard + 0.45 * forward +
#                    0.44 exper - 0.03 expersq
# Sample size = 269 observations
# R-squared = 0.3499 - i.e. 34.99% of the variation in assists completed by an NBA 
# player is explained by the variables included in this model.
# The regression for the number of assists has a better fit in this data set. We 
# also find that the statistical significance of a players experience is 
# high when wanting to predict the assists per game of a player.

