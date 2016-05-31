# -*- coding: utf-8 -*-
"""
Created on Fri May 13 09:47:40 2016

@author: mariaathena

Summary dataframe parser: parses data to add rfm field
"""

import pandas as pd
import numpy as np
#import datetime

#testdata = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1603 Digital Marketing/HomeWork 1/data/testdata.csv'
fulldata = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1603 Digital Marketing/HomeWork 1/data/DMEFExtractLinesV01.csv'

df = pd.read_csv(fulldata)

cols = df.columns.tolist()


# Helper function to avoid quintile error withn assymetric/non-unique bin edges
# http://stackoverflow.com/questions/36880490/why-use-pandas-qcut-return-valueerror-bin-edges-must-be-unique
def pct_rank_qcut(series, n):
    edges = pd.Series([float(i) / n for i in range(n + 1)])
    f = lambda x: (edges >= x).argmax()
    return series.rank(pct=1).apply(f)


# RECENCY
# Order by RECENCY i.e. OrderDate, of appeareance of Cust_ID
#type(df['OrderDate'][0])
# Order BY DESCending order, the most recent of appeareance of Cust_ID
df['OrderDate'] = df['OrderDate'].sort_values(ascending=False).reset_index(drop=True)

# Assign quintile score
#df['recency'] = np.arange(len(df))
#df['recency'] = pd.qcut(df['recency'], 5, labels=np.arange(1, 6, 1))
df['recency'] = pct_rank_qcut(df.OrderDate, 5)

# Optional: Convert OrderDate column into datatype: timeseries
#df['OrderDate'] = pd.to_datetime(pd.Series(df['OrderDate']), format='%Y%m%d')
#df['OrderDate'] = df['OrderDate'].apply(lambda x: datetime.date(x.year,x.month,x.day))


# FREQUENCY
# Create FREQUENCY column from the new count column, assign quintiles
#df['frequency'] = df.groupby('Cust_ID')['Cust_ID'].transform('count')
#df['frequency'] = pd.qcut(freq_df['count'], 5, labels=np.arange(1, 6, 1))

df['frequency'] = pct_rank_qcut(df.Cust_ID, 5)



# MONETARY
#type(df['LineDollars'][0])
# Create MONETARY column from the LineDollars column, assign quintiles
#df['monetary'] = pd.qcut(df['LineDollars'], 5, labels=np.arange(1, 6, 1))
df['monetary'] = pct_rank_qcut(df.LineDollars, 5)



# RFM
# Concatenate the RECENCY, FREQUENCY, MONETARY to a tuple in new RMF column
df['rfm'] = zip(df.recency, df.frequency, df.monetary)

# Output parsed data to csv
df.to_csv(open('rfm_parsed.csv', 'wb'), index=False)
