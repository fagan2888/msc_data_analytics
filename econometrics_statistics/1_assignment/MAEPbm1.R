### Maria Athena B. Engesaeth
### CID 01159179


##################################################################################################
##################################################################################################


## 1. Data on Chief Executive Officers for U.S.corporations
setwd("/Users/MariaAthena/Dropbox/00 Imperial College/Statistics and Econometrics/Problem Set 1")
load(file="ceosal2.RData")
desc

# A. CEO average salary: 865,864.4 USD per year. Average CEO tenure: 7.95 years
mean(data$salary)
mean(data$ceoten)
summary(data)

# B. Nb. of CEOs in their first year as CEO: 5 of the 177 surveyed CEOs. The maximum tenure of any
# of the surveyed CEOs is 37 years.
length(data$ceoten[data$ceoten==0])
max(data$ceoten)
#OR
length(which(data$ceoten==0))

# C. Average salary for CEOs with tenure >= average tenure: 1,003,500 USD per year
mean(data[data$ceoten>=mean(data$ceoten), "salary"])
# OR
x <- mean(data$ceoten)
mean(data$salary[data$ceoten >= x])
# OR
above_mean <- which(data$ceoten>=mean(data$ceoten))
mean(data$salary[above_mean])

# D. Graph examining the relationship between annual salary and CEO tenure
plot(x = data$ceoten, y = data$salary, xlab = "CEOs tenure, years",
     ylab = "CEOs Annual Salary, '000s USD", main = "CEOs Annual Salary vs Tenure",
     xlim = c(min(data$ceoten), max(data$ceoten)), ylim = c(0, max(data$salary)))
qqline(y = data$salary, ylim = c(0, max(data$salary)),
       distribution = qnorm, probs = c(0.25, 0.75), col="red")

# E. Regression/Fitted log model for the relationship between annual salary and CEO tenure: The 
# predicted increase in salary given one more year as a CEO is approximately 0.97%
# SRF: log(pred_ceo_salary) = 6.5055 + 0.0097 ceo_tenure 
# Sample size: 177 CEOs were surveyed
# R-squared: 0.0132 - this means that only 1.32% of the variation in the log(salary) is explained
# by CEO tenure. It is likely that other performance variables explain most of the variation in
# CEO salaries. Some examples of variables that directly impact CEO salaries are:
# What industries the companies operate in, something that determines profit margins. Also whether
# or not the company is publicly listed, shareholder backgrounds and interests, the size of the 
# company along with many many other factors.

salaryTenure.model <- lm(formula=log(salary)~ceoten, data=data)
summary(salaryTenure.model)


##################################################################################################
##################################################################################################


## 2. Data on births to women in the United States including information on infant birth weight 
## in ounces (bwght), and the average number of cigarettes the mother smoked per day during 
## pregnancy (cigs).
load(file="bwght.RData")

# A.  Regression/Fitted model for the relationship between birthweight and cigarettes smoked per
# day during pregnancy:
# SRF: pred_bwght = 119.7719 - 0.5137 cigs 
# Sample size: 1,388 new mothers were surveyed
# R-squared: 0.0227 - this means that only 2.27% of the variation of the predicted bwght is 
# explained the mothers smoking habits. It is likely that other variables have a higher impact on
# the variation in the bwght. Some examples of variables that directly impact the childs bwght 
# include:
# Access to prenatal care, level of income, the nutritional habits of the expectant mother, family
# structure and support, genetical predispositions as well as many many other variables.
# It may alsobe that there are not enough data points on smoking mothers in the sample size. Only
# 212 out of the 1388 or 15% of the surveyed mother reported to have been smoking during their
# pregnancy. It is possible that mothers did not want to admit to having smoked during their
# pregnancy or even that the smoking is correlated with other issues such as stress or poor 
# health or predominant in specific demographic subsets.

bwghtCigs.model <- lm(formula=bwght~cigs, data=data)
summary(bwghtCigs.model)

length(data$cigs[data$cigs>0])/length(data$cigs)

# B. The predicted bwght for when the mother smokes 0 cigs per day to when she smokes 20 cigs per 
# day is not significant given the spread in the whole sample where the median is 120 ounces. It
# would appear the correlation between the two variables is not significant.
# The predicted birth weight when cigs = 0 : approx. 119.7719 ounces
# The predicted birth weight when cigs = 20 : approx. 109.4979 ounce
desc
summary(data$bwght)


# C. This does not necessarily imply that there is a causal relationship between the child's bwght
# and the mother’s smoking habits during the pregnancy. Two main reasons for this come to mind:
# i. As outlined in question A the sample does not include many expectant mother that smoked. Either
# the regression should be done on a larger data set or with analternative regression model.
# ii. The assumption for the regression model includes assumptions that rarely hold in real life.
# Amongst those is the zero conditional mean assumption (ZCM), a restrictive assumption that states
# E(u|x) = 0 i.e. that 'x' or 'cigs' is not correlated to anything other that might affect the 
# childs bwght. Though as outlined in question A. a few suggestions come to mind that might 
# not allow this to be true in this case.


# D. To predict a birth weight of 125 ounces, cigs perday would then have to be -10.1773, which
# is a nonsensical value for number of cigarettes smoked per day. Given that the OLS model assumes
# the data is normally distributed around the estimates, negative values are not impossible. 
# Given the relatively low occurance of smaoking during pregnancy it might be better to get 
# estimates from a model that uses an alternative distribution, such as a Poisson.


# E. The fact that that the proportion of women in the sample who do not smoke while pregnant is
# about 85% reconciles with my findings and deliberation in questions A. and D.

