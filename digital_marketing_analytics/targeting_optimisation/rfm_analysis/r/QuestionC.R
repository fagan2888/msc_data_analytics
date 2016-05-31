setwd('/Users/Mia/Desktop/Digital Marketing Analytics/Homework 2')

# LOAD LIBRARIES
library(readxl)
library(ROCR)
library(aod)
library(rpart)
library(e1071)
library(SDMTools)
library(MASS)
library(ggplot2)

# READ IN TEST DATA
testdata <- read_excel("churn.xlsx", sheet = "test data set")
testdata <- na.omit(testdata)
testdata$created <- as.Date(testdata$created,format="%Y:%M:%D")
testdata$firstorder <- as.Date(testdata$firstorder,format="%Y:%M:%D")
testdata$lastorder <- as.Date(testdata$lastorder,format="%Y:%M:%D")
testdata$test <- NULL
testdata$custid <- NULL

# READ IN TRAINING DATA
traindata <- read_excel("churn.xlsx", sheet = "training data set")
traindata <- na.omit(traindata)
traindata$created <- as.Date(traindata$created,format="%Y:%M:%D")
traindata$firstorder <- as.Date(traindata$firstorder,format="%Y:%M:%D")
traindata$lastorder <- as.Date(traindata$lastorder,format="%Y:%M:%D")
traindata$train <- NULL
traindata$custid <- NULL

# DEFINE MODEL
model <- glm(retained ~., family = binomial(link='logit'), data = traindata)
summary(model)

# DECIDE WHICH PARAMETERS TO KEEP
step <- stepAIC(model, direction="both")
step$anova

# DEFINE FINAL MODEL
model_final <- glm(retained ~ created + firstorder + lastorder + esent + eopenrate + eclickrate + avgorder + refill + doorstep + favday + city,  family = binomial(link='logit'), data = traindata)
summary(model_final)

# ANALYSIS OF VARIANCE
anova(model_final, test="Chisq")
round(x = anova(model_final), digits = 4)

# GET PREDICTION
fitted.results <- predict(model, newdata = subset(testdata, type = 'response'))
fitted.results <- ifelse(fitted.results > 0.5, 1, 0)

fitted.results_final <- predict(model_final, newdata = subset(testdata, type = 'response'))
fitted.results_final <- ifelse(fitted.results_final > 0.5 , 1, 0)

# CALCULATE MISSCLASIFICATION ERROR
missclassification <- mean(fitted.results != testdata$retained)
print(paste('Accuracy is:',(1-missclassification)*100))

missclassification_final <- mean(fitted.results_final != testdata$retained)
print(paste('Accuracy is:',(1-missclassification_final)*100))

# CALCULATE CONFIDENCE INTERVAL
confint(model_final)
confint.default(model_final)

prediction <- predict(model_final, newdata = subset(testdata, type="response"))
prediction_final <- prediction(prediction, testdata$retained)
performance_final <- performance(prediction_final, measure = "tpr", x.measure = "fpr")
plot(performance_final)

areaundercurve <- performance(prediction_final, measure = "auc")
areaundercurve <- areaundercurve@y.values[[1]]
areaundercurve

# CALCULATE THE CONFUSION MATRIX
confusion.matrix(testdata$retained, fitted.results_final, threshold = 0.3)

