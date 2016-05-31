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




period_2005_2006 <- subset(data, data$orderdate >= as.Date("2005-01-06") & orders$orderdate < as.Date("2006-06-15"))
period_2006_2007 <- subset(data, data$orderdate >= as.Date("2006-06-15") & orders$orderdate < as.Date("2007-12-27"))


#################################################################################################
# MONETARY
#################################################################################################


monetary_2005_2006 <- period_2005_2006 %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))

monetary_2006_2007 <- period_2006_2007 %>%
  group_by(cust_id) %>%
  summarise(linedollars=sum(linedollars))


#################################################################################################
# FREQUENCY
#################################################################################################

# Count number of orders for each customer (per period)
frequency_2005_2006 <- period_2005_2006 %>%
  group_by(cust_id) %>%
  summarise(freq = n())

frequency_2006_2007 <- period_2006_2007 %>%
  group_by(cust_id) %>%
  summarise(freq = n())


#################################################################################################
# RECENCY
#################################################################################################

recency_2005_2006 <- period_2005_2006 %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_2005_2006$recency <- as.Date("2006-09-15") - as.Date(recency_2005_2006$date)


recency_2006_2007 <- period_2006_2007 %>%
  group_by(cust_id) %>%
  summarise(date = max(orderdate))

recency_2006_2007$recency <- as.Date("2007-12-26") - as.Date(recency_2006_2007$date)



#################################################################################################
# RFM 2005 - 2006
#################################################################################################

rfm_2005_2006 <- cbind(monetary_2005_2006, rec = as.numeric(recency_2005_2006$recency), freq = frequency_2005_2006$freq)

rfm_2005_2006 $rankF = ntile(rfm_2005_2006 $freq, 5)
rfm_2005_2006 $rankR = ntile(rfm_2005_2006 $rec, 5)
rfm_2005_2006 $rankM = ntile(rfm_2005_2006 $linedollars, 5)

rfm_2005_2006 $rfm <- paste("(",rfm_2005_2006$rankR,",",rfm_2005_2006$rankF,",",rfm_2005_2006$rankM,")",sep="")

#################################################################################################
# RFM 2006 - 2007
#################################################################################################

rfm_2006_2007 <- cbind(monetary_2006_2007, rec = as.numeric(recency_2006_2007$recency), freq = frequency_2006_2007$freq)

rfm_2006_2007 $rankF = ntile(rfm_2006_2007 $freq, 5)
rfm_2006_2007 $rankR = ntile(rfm_2006_2007 $rec, 5)
rfm_2006_2007 $rankM = ntile(rfm_2006_2007 $linedollars, 5)

rfm_2006_2007 $rfm <- paste("(",rfm_2006_2007$rankR,",",rfm_2006_2007$rankF,",",rfm_2006_2007$rankM,")",sep="")



#################################################################################################
# RESPONSE RATE
#################################################################################################
contacts_2005_2006 <- subset(contacts, contacts$contactdate < as.Date("2006-09-15"), select = c(cust_id, contactdate))
orders_2005_2006 <- period_2005_2006


contacted_2005_2006 <- contacts_2005_2006 %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

purchased_2005_2006 <- orders_2005_2006 %>%
  group_by(cust_id) %>%
  summarise(purchased = n())

# Have many purchases without prior contact
response_rate_2005_2006 <- contacted_2005_2006 %>% left_join(purchased_2005_2006, by = c('cust_id') )
response_rate_2005_2006$rate = response_rate_2005_2006$purchased/response_rate_2005_2006$contacted

#-----------------------------------------------------------#

orders_2006_2007 <- period_2006_2007

contacts_2006_2007 <- subset(contacts, contacts$contactdate >= as.Date("2006-09-15") & contacts$contactdate < as.Date("2007-12-26") , select = c(cust_id, contactdate))

contacted_2006_2007 <- contacts_2006_2007 %>%
  group_by(cust_id) %>%
  summarise(contacted = n())

purchased_2006_2007 <- orders_2006_2007 %>%
  group_by(cust_id) %>%
  summarise(purchased = n())

# Have many purchases without prior contact
response_rate_2006_2007 <- contacted_2006_2007 %>% left_join(purchased_2006_2007, by = c('cust_id') )
response_rate_2006_2007$rate = response_rate_2006_2007$purchased/response_rate_2006_2007$contacted


#################################################################################################
# COMBINE RFM WITH RESPONSE RATE
#################################################################################################

rfm_2005_2006 <- rfm_2005_2006 %>% left_join(response_rate_2005_2006, by = c("cust_id"))
rfm_2005_2006 <- na.omit(rfm_2005_2006)

rfm_2005_2006 <- subset(rfm_2005_2006, rate < 1)

#Overall contacted or contacted in that period? Does it make a difference?

customer_cells_2005_2006 <- rfm_2005_2006 %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(rate))

#----------------------------------------------------------------#

rfm_2006_2007 <- rfm_2006_2007 %>% left_join(response_rate_2006_2007, by = c("cust_id"))
rfm_2006_2007 <- na.omit(rfm_2006_2007)

rfm_2006_2007 <- subset(rfm_2006_2007, rate < 1)

#Overall contacted or contacted in that period? Does it make a difference?

customer_cells_2006_2007 <- rfm_2006_2007 %>%
  group_by(rfm) %>%
  summarise(count = n(),
            average_rate = mean(rate))












library(ggplot2)
library(lattice)

hist(rfm_2001$linedollars, breaks = 40, col = 'yellow', xlab="Miles Per Gallon", main="Histogram with Normal Curve" )

hist(rfm_2001$rec)
hist(rfm_2001$freq)


