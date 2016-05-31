setwd('/Users/Mia/Google Drive/1603_digital_marketing_analytics/DMA_HW1/rfm_analysis')

# v1.2 included orderdate contactdate

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

# could calculate differently by looking at purchases made as response to contact:
# (purchase made in response to contacted)/total contacted
# have to set timeframe for that one
# right now we are doing:
# (purchases made)/total contacted
# we'd loose orders that were made with no prior contact

contacted_ordered <- left_join(contacts, orders, by ='cust_id')
contacted_ordered <- subset(contacted_ordered, contacted_ordered$orderdate >= as.Date("2005-01-06"))
contacted_ordered$diff = as.Date(contacted_ordered$contactdate) - as.Date(contacted_ordered$orderdate)


orders_in_response <- subset(contacted_ordered, as.Date(contacted_ordered$contactdate) - as.Date(contacted_ordered$orderdate) > - 32 & as.Date(contacted_ordered$contactdate) - as.Date(contacted_ordered$orderdate) < 0)


orders_new <- orders_in_response %>%
  group_by(ordernum) %>%
  mutate(diff = max(diff)) %>%
  distinct(ordernum)


ids <- contacts 
ids <- subset(ids, ids$contactdate >= as.Date("2005-01-06"))
ids <- ids %>%
  distinct(cust_id) %>%
  select(cust_id)


recency <- orders_new 
recency <- subset(recency, recency$orderdate >= as.Date("2005-01-06")) %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))


frequency <- orders_new 
frequency <- subset(frequency, frequency$orderdate >= as.Date("2005-01-06")) %>%
  group_by(cust_id)  %>%
  summarise(total_purchase = n())


monetary <- lines
monetary <- subset(monetary, monetary$orderdate >= as.Date("2005-01-06")) %>%
  group_by(cust_id)  %>%
  summarise(total_value = sum(linedollars))


response_rate <- contacts %>%
  group_by(cust_id)  %>%
  summarise(total_contacted = n())


#################################################################################################
# DATA
#################################################################################################

data <- left_join(ids, frequency, by='cust_id')
data$total_purchase[is.na(data$total_purchase)] <- 0

data <- left_join(data,recency,by='cust_id')
data$date[is.na(data$date)] <- as.Date("2005-01-06")

data <- left_join(data,monetary,by='cust_id')
data$total_value[is.na(data$total_value)] <- 0

data <- left_join(data,response_rate,by='cust_id')
data$response_rate = data$total_purchase/data$total_contacted


#################################################################################################
# SPLIT TEST AND TRAINING
#################################################################################################

rfm_training <- sample_n(data, length(unique(data$cust_id))*0.5)
rfm_test <- subset(data, !(data$cust_id %in% rfm_training$cust_id))



rfm_training$rankF = ntile(rfm_training$total_purchase, 5)
rfm_training$rankR = ntile(rfm_training$date, 5)
rfm_training$rankM = ntile(rfm_training$total_value, 5)
rfm_training$rfm <- paste("(",rfm_training$rankR,",",rfm_training$rankF,",",rfm_training$rankM,")",sep="")


rfm_test$rankF = ntile(rfm_test$total_purchase, 5)
rfm_test$rankR = ntile(rfm_test$date, 5)
rfm_test$rankM = ntile(rfm_test$total_value, 5)
rfm_test$rfm <- paste("(",rfm_test$rankR,",",rfm_test$rankF,",",rfm_test$rankM,")",sep="")


rfm_training <- subset(rfm_training, response_rate < 1)
rfm_test <- subset(rfm_test, response_rate < 1)

#################################################################################################
# LOOK AT CELL
#################################################################################################

customer_cells_training <- rfm_training %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(response_rate)) %>%
  arrange(desc(average_rate))


customer_cells_test <- rfm_test %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(response_rate)) %>%
  arrange(desc(average_rate))

#################################################################################################
# PLOTS
#################################################################################################


library(ggplot2)
library(lattice)

hist(rfm_training$total_value, breaks = 500, col = 'mediumpurple4',ylab = 'Count of Customers', xlab="Total Transaction Value", main="Histogram of Transaction Values" , xlim = c(1,200))
hist(rfm_training$total_contacted ,breaks = 50, col = 'mediumpurple4', ylab = 'Count of Customers', xlab="Total Communication per Customer", main="Histogram of Communications" , xlim = c(1,100))

hist(rfm_2005_2006$freq)

#################################################################################################
# WRITE OUTPUT
#################################################################################################


write.csv(customer_cells_training, file = "customer_cells_traning_random_14days.csv", append = FALSE, quote = TRUE,
          col.names = TRUE)

write.csv(customer_cells_test, file = "customer_cells_test_random_14days.csv", append = FALSE, quote = TRUE,
          col.names = TRUE)
