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


# Calculate total price per order (over whole period)
ordernumprices <- lines %>%
  group_by(ordernum) %>%
  summarise(linedollars=sum(linedollars)) %>%
  arrange(ordernum)


data <- orders %>% left_join(ordernumprices, by = c("ordernum"))

#################################################################################################
# Calculate Recency
#################################################################################################

min(orders$orderdate)
# "2001-01-01"
max(orders$orderdate)
# "2008-01-01"

training <- sample_n(data, length(unique(data$cust_id))/2)
test <- subset(data, !(data$cust_id %in% training$cust_id))

# length(unique(data$cust_id))
# 100051

#################################################################################################
# MONETARY
#################################################################################################


monetary_traingin <- training %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))

monetary_test <- test %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))



#################################################################################################
# FREQUENCY
#################################################################################################

# Count number of orders for each customer (per period)
frequency_training <- training %>%
  group_by(cust_id) %>%
  summarise(freq = n())

frequency_2005_2008 <- period_2005_2008 %>%
  group_by(cust_id) %>%
  summarise(freq = n())


#################################################################################################
# RECENCY
#################################################################################################

recency_2001_2005 <- period_2001_2005 %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))
recency_2001_2005$recency <- as.Date("2005-01-06") - as.Date(recency_2001_2005$date)


recency_2005_2008 <- period_2005_2008 %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))
recency_2005_2008$recency <- as.Date("2007-12-26") - as.Date(recency_2005_2008$date)



#################################################################################################
# RFM 2001 - 2005
#################################################################################################

rfm_2001_2005 <- cbind(monetary_2001_2005, rec = as.numeric(recency_2001_2005$recency), freq = frequency_2001_2005$freq)

rfm_2001_2005 $rankF = ntile(rfm_2001_2005 $freq, 5)
rfm_2001_2005 $rankR = ntile(rfm_2001_2005 $rec, 5)
rfm_2001_2005 $rankM = ntile(rfm_2001_2005 $linedollars, 5)

rfm_2001_2005 $rfm <- paste("(",rfm_2001_2005$rankR,",",rfm_2001_2005$rankF,",",rfm_2001_2005$rankM,")",sep="")



#################################################################################################
# RFM 2005 - 2008
#################################################################################################

rfm_2005_2008 <- cbind(monetary_2005_2008, rec = as.numeric(recency_2005_2008$recency), freq = frequency_2005_2008$freq)

rfm_2005_2008 $rankF = ntile(rfm_2005_2008 $freq, 5)
rfm_2005_2008 $rankR = ntile(rfm_2005_2008 $rec, 5)
rfm_2005_2008 $rankM = ntile(rfm_2005_2008 $linedollars, 5)

rfm_2005_2008 $rfm <- paste("(",rfm_2005_2008$rankR,",",rfm_2005_2008$rankF,",",rfm_2005_2008$rankM,")",sep="")


#################################################################################################
# RESPONSE RATE
#################################################################################################
contacts_2001_2005 <- subset(contacts, contacts$contactdate < as.Date("2005-01-06"), select = c(cust_id, contactdate))
orders_2001_2005 <- period_2001_2005

contacted_2001_2005 <- contacts_2001_2005 %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

purchased_2001_2005 <- orders_2001_2005 %>%
  group_by(cust_id) %>%
  summarise(purchased = n())


contacts_2005_2008 <- subset(contacts, contacts$contactdate >= as.Date("2005-01-06"), select = c(cust_id, contactdate))
orders_2005_2008 <- period_2005_2008


data <- orders %>% left_join(ordernumprices, by = c("ordernum"))



df <- orders_2005_2008 %>% left_join(contacts_2005_2008, by = c("cust_id"))
df$diff <- as.Date(df$contactdate) - as.Date(df$orderdate)


final <- subset(df, as.numeric(df$diff) > -31 & as.numeric(df$diff) < 0)



final2 <- final %>%
  group_by(ordernum) %>%
  mutate(most_recent = max(diff)) %>%
  distinct() %>%
  select(cust_id,orderdate,contactdate,linedollars, most_recent)


unique_visit <- coffee_clean %>% 
  select(house, shop_desc_clean, relweek, day) %>% 
  distinct() %>% 
  mutate(visit_id = row_number())



# Have many purchases without prior contact
response_rate <- contacted_2001_2005 %>% left_join(purchased_2001_2005, by = c('cust_id') )
response_rate$rate = response_rate$purchased/response_rate$contacted


#################################################################################################
# COMBINE RFM WITH RESPONSE RATE
#################################################################################################

rfm_2001 <- rfm_2001 %>% left_join(response_rate, by = c("cust_id"))
rfm_2001 <- na.omit(rfm_2001)

#Overall contacted or contacted in that period? Does it make a difference?

customer_cells_2001 <- rfm_2001 %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(rate))



countC <- contacts %>%
  group_by(contacttype) %>%
  summarise(count = n())



library(ggplot2)
library(lattice)

hist(rfm_2001$linedollars, breaks = 40, col = 'yellow', xlab="Miles Per Gallon", main="Histogram with Normal Curve" )

hist(rfm_2001$rec)
hist(rfm_2001$freq)


