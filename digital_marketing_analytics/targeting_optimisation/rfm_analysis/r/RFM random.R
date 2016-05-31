setwd('/Users/Mia/Google Drive/1603_digital_marketing_analytics/DMA_HW1/rfm_analysis')
# install.packages("mlogit")
library(dplyr)
library(mlogit)
library(readr)
library(ggplot2)
library(tidyr)

#################################################################################################
# Read in the file as dataframe and set column names from CSV as uppcase for dataframe
#################################################################################################

# Import lines file
lines <- read.csv("lines.csv", 
                    encoding = "latin1", 
                    stringsAsFactors = FALSE) %>% 
  as_data_frame()

#lines <- na.omit(lines) don't omit or money wont work
colnames(lines) <- lines %>% colnames() %>% tolower()
lines$orderdate <- as.Date(as.character(lines$orderdate), format="%Y%m%d")



# Import orders file: Contains unique orderdate - use for recency
orders <- read.csv("orders.csv", 
                  encoding = "latin1", 
                  stringsAsFactors = FALSE) %>% 
  as_data_frame()

orders <- na.omit(orders)
colnames(orders) <- orders %>% colnames() %>% tolower()
orders$orderdate <- as.Date(as.character(orders$orderdate), format="%Y%m%d")


# Import contacts file
contacts <- read.csv("contacts.csv", 
                    encoding = "latin1", 
                    stringsAsFactors = FALSE) %>% 
  as_data_frame()
contacts <- na.omit(contacts)
colnames(contacts) <- contacts %>% colnames() %>% tolower()
contacts$contactdate <- as.Date(as.character(contacts$contactdate), format="%Y%m%d")


# Calculate total price per order (over whole period where contacted)
ordernumprices <- subset(lines, lines$orderdate > as.Date("2005-01-06")) %>%
  group_by(ordernum) %>%
  summarise(linedollars=sum(linedollars)) 


data <- orders 
data <- subset(data, data$orderdate >= as.Date("2005-01-06"))
data <- data %>%
  distinct(cust_id)

#################################################################################################
# SPLIT TEST AND TRAINING
#################################################################################################

training <- sample_n(data, length(unique(data$cust_id))*0.5)
test <- subset(data, !(data$cust_id %in% training$cust_id))


#################################################################################################
# MONETARY
#################################################################################################

monetary_training <- subset(lines, lines$cust_id %in% training$cust_id & lines$orderdate > as.Date("2005-06-01")) %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))

monetary_test <- subset(lines, lines$cust_id %in% test$cust_id & lines$orderdate > as.Date("2005-06-01")) %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))

#################################################################################################
# FREQUENCY
#################################################################################################

# Count number of orders for each customer (per period)
frequency_training <- subset(orders, orders$cust_id %in% training$cust_id & orders$orderdate > as.Date("2005-06-01")) %>%
  group_by(cust_id) %>%
  summarise(freq = n())

frequency_test <- subset(orders, orders$cust_id %in% test$cust_id & orders$orderdate > as.Date("2005-06-01")) %>%
  group_by(cust_id) %>%
  summarise(freq = n())


#################################################################################################
# RECENCY
#################################################################################################

recency_training <- subset(orders, orders$cust_id %in% training$cust_id & orders$orderdate > as.Date("2005-06-01")) %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_training$recency <- as.Date("2007-12-26") - as.Date(recency_training$date)


recency_test <- subset(orders, orders$cust_id %in% test$cust_id & orders$orderdate > as.Date("2005-06-01")) %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_test$recency <- as.Date("2007-12-26") - as.Date(recency_test$date)


#################################################################################################
# RFM training
#################################################################################################

rfm_training<- cbind(monetary_training, rec = as.numeric(recency_training$recency), freq = frequency_training$freq)

rfm_training$rankF = ntile(rfm_training$freq, 5)
rfm_training$rankR = ntile(rfm_training$rec, 5)
rfm_training$rankM = ntile(rfm_training$linedollars, 5)

rfm_training$rfm <- paste("(",rfm_training$rankR,",",rfm_training$rankF,",",rfm_training$rankM,")",sep="")

#################################################################################################
# RFM test
#################################################################################################

rfm_test <- cbind(monetary_test, rec = as.numeric(recency_test$recency), freq = frequency_test$freq)

rfm_test$rankF = ntile(rfm_test$freq, 5)
rfm_test$rankR = ntile(rfm_test$rec, 5)
rfm_test$rankM = ntile(rfm_test$linedollars, 5)

rfm_test$rfm <- paste("(",rfm_test$rankR,",",rfm_test$rankF,",",rfm_test$rankM,")",sep="")



#################################################################################################
# RESPONSE RATE
#################################################################################################
contacts_training <- subset(contacts, contacts$cust_id %in% training$cust_id) 
orders_training <- subset(orders, orders$cust_id %in% training$cust_id & orders$orderdate > as.Date("2005-06-01"))

contacts_test<- subset(contacts, contacts$cust_id %in% test$cust_id) 
orders_test <- subset(orders, orders$cust_id %in% test$cust_id & orders$orderdate > as.Date("2005-06-01"))

#################################################################################################
contacted_training <- contacts_training  %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

purchased_training <- orders_training %>%
  group_by(cust_id) %>%
  summarise(purchased = n())

#################################################################################################
contacted_test <- contacts_test  %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

purchased_test <- orders_test %>%
  group_by(cust_id) %>%
  summarise(purchased = n())
#################################################################################################

response_rate_training <- contacted_training  %>% left_join(purchased_training, by = c('cust_id') )
response_rate_training$rate = response_rate_training$purchased/response_rate_training$contacted
#################################################################################################

response_rate_test <- contacted_test  %>% left_join(purchased_test, by = c('cust_id') )
response_rate_test$rate = response_rate_test$purchased/response_rate_test$contacted


#################################################################################################
# COMBINE RFM WITH RESPONSE RATE
#################################################################################################

rfm_training <- rfm_training %>% left_join(response_rate_training, by = c("cust_id"))
rfm_training <- na.omit(rfm_training)
rfm_training <- subset(rfm_training, rate < 1)

# Omit to exclude the ones that were contacted but did not make a purchase

rfm_test<- rfm_test %>% left_join(response_rate_test, by = c("cust_id"))
rfm_test <- na.omit(rfm_test)
rfm_test <- subset(rfm_test, rate < 1)

#################################################################################################
# LOOK AT CELL
#################################################################################################

customer_cells_training <- rfm_training %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(rate))


customer_cells_test <- rfm_test %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(rate))



