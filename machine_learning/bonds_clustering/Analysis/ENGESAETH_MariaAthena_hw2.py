# -*- coding: utf-8 -*-
"""
Created on Mon Mar 28 10:03:27 2016

@author: mariaathena
"""

import pandas as pd


# Filepaths
CorporateBond = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1601 Machine Learning/Assignment 2/Data (csv)/CorporateBond.csv'
MunicipalBond = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1601 Machine Learning/Assignment 2/Data (csv)/MunicipalBond.csv'
stockreturn2 = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1601 Machine Learning/Assignment 2/Data (csv)/stockreturn2.csv'

corp_df = pd.DataFrame.from_csv(CorporateBond)
muni_df = pd.DataFrame.from_csv(MunicipalBond)
stock_df = pd.DataFrame.from_csv(stockreturn2)


# Take Rating strings out of quotations
corp_df.Rating = corp_df['Rating'].apply(lambda x: x.replace("'", ""))
muni_df.Rating = muni_df['Rating'].apply(lambda x: x.replace("'", ""))

# Convert Maturity field from string to timeseries and set as index
corp_df.Maturity = pd.to_datetime(corp_df.Maturity, dayfirst=True).dt.date
corp_df.set_index(['Maturity'], inplace=True)
corp_df.sort_index(inplace=True)
corp_df.drop(corp_df.index[-1], inplace=True)

muni_df.Maturity = pd.to_datetime(muni_df.Maturity, dayfirst=True).dt.date
muni_df.set_index(['Maturity'], inplace=True)
muni_df.sort_index(inplace=True)


# Create dummy variable columns of Rating field
#corp_df = pd.concat([corp_df, pd.get_dummies(corp_df.Rating, prefix='Rating_')], axis=1)
#muni_df = pd.concat([muni_df, pd.get_dummies(muni_df.Rating, prefix='Rating_')], axis=1)

# Change Order of that Ratings_ appear
#corp_df = corp_df[['Price', 'Coupon', 'YTM', 'CurrentYield', 'Rating', 'Rating__AAA', 'Rating__AA', 'Rating__A', 'Rating__BBB', 'Rating__BB', 'Rating__B', 'Rating__CCC', 'Rating__CC']]
#muni_df = corp_df[['Price', 'Coupon', 'YTM', 'CurrentYield', 'Rating', 'Rating__AAA', 'Rating__AA', 'Rating__A', 'Rating__BBB']]

