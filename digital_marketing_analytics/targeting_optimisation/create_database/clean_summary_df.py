# -*- coding: utf-8 -*-
"""
Created on Tue May 10 11:37:27 2016

@author: mariaathena
"""

import pandas as pd


summary = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1603 Digital Marketing Analytics/HomeWork/data/DMEFExtractSummaryV01.csv'

df = pd.read_csv(summary)

#colnames = df.columns.tolist()
#df.concat(df.columns[[]], axis=1, inplace=True)
#df = df.drop(df.columns[[2, 3, 6]], axis=1, inplace=True)

df_out = pd.concat([df['Cust_ID'], df['SCF_Code']], 
                   axis=1, 
                   keys=['Cust_ID', 'SCF_Code'])

# Joining dataframes to export as csv
df_out.to_csv(open('location.csv', 'wb'), index=False)
