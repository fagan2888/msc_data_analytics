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


period_2001_2003 <- subset(data, data$orderdate < as.Date("2003-12-31"))
period_2003_2005 <- subset(data, data$orderdate > as.Date("2003-12-31") & orders$orderdate < as.Date("2005-12-31"))
period_2005_2007 <- subset(data, data$orderdate > as.Date("2005-12-31") & orders$orderdate < as.Date("2007-12-31"))


#################################################################################################
# MONETARY
#################################################################################################


monetary_2001_2003 <- period_2001_2003 %>%
    group_by(cust_id) %>%
    summarise(linedollars=sum(linedollars))

monetary_2003_2005 <- period_2003_2005 %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))

monetary_2005_2007 <- period_2005_2007 %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))

  
#################################################################################################
# FREQUENCY
#################################################################################################

# Count number of orders for each customer (per period)
frequency_2001_2003 <- period_2001_2003 %>%
  group_by(cust_id) %>%
  summarise(freq = n())

frequency_2003_2005 <- period_2003_2005 %>%
  group_by(cust_id) %>%
  summarise(freq = n())

frequency_2005_2007 <- period_2005_2007 %>%
  group_by(cust_id) %>%
  summarise(freq = n())


#################################################################################################
# RECENCY
#################################################################################################

recency_2001_2003 <- period_2001_2003 %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_2001_2003$recency <- as.Date("2003-12-31") - as.Date(recency_2001_2003$date)


recency_2003_2005 <- period_2003_2005 %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_2003_2005$recency <- as.Date("2005-12-31") - as.Date(recency_2003_2005$date)


recency_2005_2007 <- period_2005_2007 %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_2005_2007$recency <- as.Date("2007-12-31") - as.Date(recency_2005_2007$date)



#################################################################################################
# RFM 2001 - 2003
#################################################################################################

rfm_2001_2003 <- cbind(monetary_2001_2003, rec = as.numeric(recency_2001_2003$recency), freq = frequency_2001_2003$freq)

rfm_2001_2003 $rankF = ntile(rfm_2001_2003 $freq, 5)
rfm_2001_2003 $rankR = ntile(rfm_2001_2003 $rec, 5)
rfm_2001_2003 $rankM = ntile(rfm_2001_2003 $linedollars, 5)

rfm_2001_2003 $rfm <- paste("(",rfm_2001_2003$rankR,",",rfm_2001_2003$rankF,",",rfm_2001_2003$rankM,")",sep="")

#################################################################################################
# RFM 2003 - 2005
#################################################################################################

rfm_2003_2005 <- cbind(monetary_2003_2005, rec = as.numeric(recency_2003_2005$recency), freq = frequency_2003_2005$freq)

rfm_2003_2005 $rankF = ntile(rfm_2003_2005 $freq, 5)
rfm_2003_2005 $rankR = ntile(rfm_2003_2005 $rec, 5)
rfm_2003_2005 $rankM = ntile(rfm_2003_2005 $linedollars, 5)

rfm_2003_2005 $rfm <- paste("(",rfm_2003_2005$rankR,",",rfm_2003_2005$rankF,",",rfm_2003_2005$rankM,")",sep="")


#################################################################################################
# RFM 2005 - 2007
#################################################################################################

rfm_2005_2007 <- cbind(monetary_2005_2007, rec = as.numeric(recency_2005_2007$recency), freq = frequency_2005_2007$freq)

rfm_2005_2007 $rankF = ntile(rfm_2005_2007 $freq, 5)
rfm_2005_2007 $rankR = ntile(rfm_2005_2007 $rec, 5)
rfm_2005_2007 $rankM = ntile(rfm_2005_2007 $linedollars, 5)

rfm_2005_2007 $rfm <- paste("(",rfm_2005_2007$rankR,",",rfm_2005_2007$rankF,",",rfm_2005_2007$rankM,")",sep="")



#################################################################################################
# RESPONSE RATE
#################################################################################################
contacts_2001_2003 <- subset(contacts, contacts$contactdate < as.Date("2003-12-31"), select = c(cust_id, contactdate))
orders_2001_2003 <- period_2001_2003

contacts_2001_2003 <- subset(contacts, contacts$contactdate < as.Date("2005-12-31") & contacts$contactdate > as.Date("2003-12-31") , select = c(cust_id, contactdate))


contacted_2001_2003 <- contacts_2001_2003 %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

purchased_2001_2003 <- orders_2001_2003 %>%
  group_by(cust_id) %>%
  summarise(purchased = n())

# Have many purchases without prior contact
response_rate <- contacted %>% left_join(purchased, by = c('cust_id') )
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


