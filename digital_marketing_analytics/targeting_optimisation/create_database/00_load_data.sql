
-- Load data into SQL dataframe

DROP TABLE contacts;

CREATE TABLE contacts
(
Cust_ID VARCHAR,
ContactDate DATE,
ContactType VARCHAR
);


COPY contacts FROM '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1603 Digital Marketing Analytics/HomeWork/data/DMEFExtractContactsV01.csv' WITH CSV HEADER;

DROP TABLE lines;
CREATE TABLE lines
(
Cust_ID VARCHAR,
OrderNum VARCHAR,
OrderDate DATE,
LineDollars FLOAT,
Gift VARCHAR,
RecipNum VARCHAR
);

COPY lines FROM '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1603 Digital Marketing Analytics/HomeWork/data/DMEFExtractLinesV01.csv' WITH CSV HEADER;


DROP TABLE orders;
CREATE TABLE orders
(
Cust_ID VARCHAR,
OrderNum VARCHAR,
OrderDate DATE,
OrderMethod VARCHAR,
PaymentType VARCHAR
);

COPY orders FROM '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1603 Digital Marketing Analytics/HomeWork/data/DMEFExtractOrdersV01.csv' WITH CSV HEADER;


CREATE TABLE location
(
Cust_ID VARCHAR,
SCF_Code VARCHAR
);

COPY location FROM '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1603 Digital Marketing Analytics/HomeWork/data/location.csv' WITH CSV HEADER;



