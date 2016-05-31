setwd('/Users/Mia/Google Drive/1603_digital_marketing_analytics/DMA_HW1/rfm_analysis')

# SPLIT CUSTOMER DATA MID 2006 BASED ON CONTACTED
# NO 14 DAY TIME DIFFERENCE FOR RESPONSE RATE CALCULATION
# PURCHASES WITH NO PRIOR CONTACT WILL BE IGNORED (CAN'T COUNT AS RESPONSE) - THEREFORE ANALYSIS IS BASED ON CONTACTS FILE
# CONTACTED WITH NO PURCHASE IS SET TO 0 AS RESPONSE RATE
# CUSTOMERS WITH > 1 RESPONSE IGNORED.SETTING THEM TO 1 NOT GOOD FOR RESULTS.

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




ids <- contacts 
ids <- subset(ids, ids$contactdate >= as.Date("2005-01-06"))
ids <- ids %>%
  distinct(cust_id) %>%
  select(cust_id,contactdate,-contacttype) 


data <- ids

#################################################################################################
# Calculate Recency
#################################################################################################


period_2005_2006 <- subset(data, data$contactdate >= as.Date("2005-01-06") & data$contactdate < as.Date("2006-12-31"))
period_2006_2007 <- subset(data, data$contactdate >= as.Date("2006-12-31") & data$contactdate < as.Date("2007-12-27"))


#################################################################################################
# MONETARY
#################################################################################################


monetary_2005_2006 <- subset(lines, lines$orderdate >= as.Date("2005-01-06") & lines$orderdate < as.Date("2006-12-31") ) %>%
  group_by(cust_id) %>%
  summarise(total_value = sum(linedollars))

monetary_2006_2007 <- subset(lines, lines$orderdate >= as.Date("2006-12-31") & lines$orderdate < as.Date("2007-12-27") ) %>%
  group_by(cust_id) %>%
  summarise(total_value = sum(linedollars))


#################################################################################################
# RECENCY
#################################################################################################


recency_2005_2006 <- subset(orders, orders$orderdate >= as.Date("2005-01-06") & orders$orderdate < as.Date("2006-12-31")) %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_2005_2006$recency <- -(as.Date("2006-12-31") - as.Date(recency_2005_2006$date))


recency_2006_2007 <- subset(orders, orders$orderdate >= as.Date("2006-12-31") & orders$orderdate < as.Date("2007-12-27")) %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_2006_2007$recency <- -(as.Date("2007-12-26") - as.Date(recency_2006_2007$date))


#################################################################################################
# FREQUENCY
#################################################################################################

# Count number of orders for each customer (per period)
frequency_2005_2006 <- subset(orders, orders$orderdate >= as.Date("2005-01-06") & orders$orderdate < as.Date("2006-12-31")) %>%
  group_by(cust_id) %>%
  distinct(ordernum) %>%
  summarise(freq = n())

frequency_2006_2007 <- subset(orders, orders$orderdate >= as.Date("2006-12-31") & orders$orderdate < as.Date("2007-12-27")) %>%
  group_by(cust_id) %>%
  distinct(ordernum) %>%
  summarise(freq = n())

#################################################################################################
# RESPONSE RATE 2005 - 2006
#################################################################################################


contacts_2005_2006 <- subset(contacts, contacts$contactdate >= as.Date("2005-01-06") & contacts$contactdate < as.Date("2006-12-31")) 
contacted_2005_2006 <- contacts_2005_2006 %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

orders_2005_2006 <- subset(orders, orders$orderdate >= as.Date("2005-01-06") & orders$orderdate < as.Date("2006-12-31")) 
purchased_2005_2006 <- orders_2005_2006 %>%
  group_by(cust_id) %>%
  summarise(purchased = n()) #WRONG


response_rate_2005_2006 <- contacted_2005_2006 %>% left_join(purchased_2005_2006, by = c('cust_id'))
response_rate_2005_2006$rate = response_rate_2005_2006$purchased/response_rate_2005_2006$contacted

#################################################################################################
# RESPONSE RATE 2006 - 2007
#################################################################################################


contacts_2006_2007 <- subset(contacts, contacts$contactdate >= as.Date("2006-12-31") & contacts$contactdate < as.Date("2007-12-27")) 
contacted_2006_2007 <- contacts_2006_2007 %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

orders_2006_2007 <- subset(orders, orders$orderdate >= as.Date("2006-12-31") & orders$orderdate < as.Date("2007-12-27"))
purchased_2006_2007 <- orders_2006_2007 %>%
  group_by(cust_id) %>%
  summarise(purchased = n())


response_rate_2006_2007 <- contacted_2006_2007 %>% left_join(purchased_2006_2007, by = c('cust_id'))
response_rate_2006_2007$rate = response_rate_2006_2007$purchased/response_rate_2006_2007$contacted


#################################################################################################
# RFM 2005 - 2006
#################################################################################################


rfm_2005_2006 <- left_join(period_2005_2006,recency_2005_2006, by='cust_id')
rfm_2005_2006$date[is.na(rfm_2005_2006$date)] <- "2005-01-06"
rfm_2005_2006 <- left_join(rfm_2005_2006,monetary_2005_2006, by='cust_id')
rfm_2005_2006 <- left_join(rfm_2005_2006,frequency_2005_2006, by='cust_id')
rfm_2005_2006 <- left_join(rfm_2005_2006,response_rate_2005_2006,by='cust_id')
rfm_2005_2006[is.na(rfm_2005_2006)] <- 0
#rfm_2005_2006$rate[rfm_2005_2006$rate >= 1] <- 1


rfm_2005_2006$rankF = ntile(rfm_2005_2006$freq, 5)
rfm_2005_2006$rankR = ntile(rfm_2005_2006$date, 5)
rfm_2005_2006$rankM = ntile(rfm_2005_2006$total_value, 5)

rfm_2005_2006$rfm <- paste("(",rfm_2005_2006$rankR,",",rfm_2005_2006$rankF,",",rfm_2005_2006$rankM,")",sep="")


#################################################################################################
# RFM 2006 - 2007
#################################################################################################
rfm_2006_2007 <- left_join(period_2006_2007,recency_2006_2007, by='cust_id')
rfm_2006_2007$date[is.na(rfm_2006_2007$date)] <- "2006-12-31"
rfm_2006_2007 <- left_join(rfm_2006_2007,monetary_2006_2007, by='cust_id')
rfm_2006_2007 <- left_join(rfm_2006_2007,frequency_2006_2007, by='cust_id')
rfm_2006_2007 <- left_join(rfm_2006_2007,response_rate_2006_2007,by='cust_id')
rfm_2006_2007[is.na(rfm_2006_2007)] <- 0
#rfm_2006_2007$rate[rfm_2006_2007$rate >= 1] <- 1

rfm_2006_2007$rankF = ntile(rfm_2006_2007$freq, 5)
rfm_2006_2007$rankR = ntile(rfm_2006_2007$date, 5)
rfm_2006_2007$rankM = ntile(rfm_2006_2007$total_value, 5)

rfm_2006_2007$rfm <- paste("(",rfm_2006_2007$rankR,",",rfm_2006_2007$rankF,",",rfm_2006_2007$rankM,")",sep="")

#################################################################################################
# CUSTOMER CELLS 2005 - 2006
#################################################################################################

# Remove next line and uncomment line above to set rate === 1
rfm_2005_2006 <- subset(rfm_2005_2006, rate < 1)

customer_cells_2005_2006 <- rfm_2005_2006 %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(rate)) %>%
  arrange(desc(average_rate))


#################################################################################################
# CUSTOMER CELLS 2006 - 2007
#################################################################################################

# Remove next line and uncomment line above to set rate === 1
rfm_2006_2007 <- subset(rfm_2006_2007, rate < 1)

customer_cells_2006_2007 <- rfm_2006_2007 %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(rate)) %>%
  arrange(desc(average_rate))



#################################################################################################
# PLOTS
#################################################################################################


library(ggplot2)
library(lattice)

hist(rfm_2005_2006$linedollars, breaks = 40, col = 'yellow', xlab="", main="" )
hist(rfm_2005_2006$rec)
hist(rfm_2005_2006$freq)


#################################################################################################
# WRITE OUTPUT
#################################################################################################


write.csv(customer_cells_2006_2007, file = "customer_cells_2006_2007_no14days.csv", append = FALSE, quote = TRUE,
          col.names = TRUE)

write.csv(customer_cells_2005_2006, file = "customer_cells_2005_2006_no14days.csv", append = FALSE, quote = TRUE,
          col.names = TRUE)

