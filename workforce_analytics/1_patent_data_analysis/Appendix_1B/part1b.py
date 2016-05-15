# -*- coding: utf-8 -*-
"""
Created on Thu Feb 18 21:35:27 2016

Worforce Analytics - Part Ib

@author: MariaAthena
"""

import pickle
import pandas as pd
from collections import Counter
import jellyfish


# Input data file
input_datafile = '/Users/MariaAthena/Dropbox/00 Imperial College/1601 Workforce Analytics/Assignments/BS1810_IndividualPart1_EngesaethMaria/Data/D3_patent_data.csv'

# Load data file containing required data to create ethnicity dictionary
ethnicfile = open('/Users/MariaAthena/Dropbox/00 Imperial College/1601 Workforce Analytics/Assignments/BS1810_IndividualPart1_EngesaethMaria/Data/D4name_ethnicity.pkl', 'rb')
# Create ethnicity_dict: {'names': 'ethnicity of name'}
ethnicity_dict = pickle.load(ethnicfile)
ethnicfile.close()

# loops through ethnicity_dict changes each key to its metaphone equivalent
for key in ethnicity_dict.keys():
    phonetic_key = jellyfish.metaphone(unicode(key))
    # replaces phonetic key with old key
    ethnicity_dict[phonetic_key] = ethnicity_dict.pop(key)


# Helper functions

# Calculating the Herfindahl index
def herfindahl(input_list):
    cntry_cnt = Counter(input_list)
    vals = cntry_cnt.values()
    prob = 0
    for val in vals:
        prob = prob + (val / float(sum(vals))) ** 2
    return prob


# Converting list of strings into their metaphone equivalent
def metaph(list_in_df):
    new_list = []
    for tx in list_in_df:
        metaph_equiv = jellyfish.metaphone(unicode(tx))
        new_list.append(metaph_equiv)
    return new_list


# Matching a metphone name to its nationality in the ethnicity dictionary
def nationality(also_list_in_df):
    ethnicity_dict
    newer_list = []
    for meta in also_list_in_df:
        for dict_meta, dict_nation in ethnicity_dict.items():

            if meta == dict_meta:
                newer_list.append(dict_nation)
                break

    return newer_list


# Company ethnicity

## Create pandas DataFrame from input ethnicfile
#df_eth = pd.read_csv(ethnicfile)
## Get column labels in rows then rename columns
#df_eth = pd.melt(df_eth)
#df_eth.columns = ['ethnicity', 'names']
## Change content of column 'names' into metaphone equivalent
#df_eth.names = df_eth.names.apply(lambda x: jellyfish.metaphone(unicode(x)))

# Create pandas DataFrame from input datafile
df = pd.read_csv(input_datafile)
# Drop columns: year, performance, cntries
df.drop(df.columns[[2, 3, 6]], axis=1, inplace=True)
# Change string in lastname column into list of strings
df['lastname'] = df['lastname'].str.split('; ')
# Change column content of lastnames into metaphone equivalent
df.lastname = df.lastname.apply(lambda x: metaph(x))
# Change column content of lastnames into ethnicity of lastname
df.lastname = df.lastname.apply(lambda x: nationality(x))
# Rename lastname column to 'ethnicities'
df.columns = ['pnum', 'firm', 'inv_num', 'ethnicities']

# Groupby firm ticker, rename columns, remove duplicates and calc herfindahl
# Counting number of patents
df_nb_patents = df.groupby('firm')['pnum'].count().reset_index()
df_nb_patents.columns = ['firm', 'nb_of_patents']
# For Herfindahl index
df_ethn = df.groupby('firm')['ethnicities'].sum().reset_index()
df_ethn.columns = ['firm', 'herfindahl']
df_ethn.herfindahl = df_ethn.herfindahl.apply(lambda x: set(x))
df_ethn.herfindahl = df_ethn.herfindahl.apply(lambda x: herfindahl(x))

# Firm DataFrame
firm_df = pd.merge(df_ethn, df_nb_patents,
                   left_on='firm', right_on='firm', how='left')


# Look at number of inventors that moved firms
# Create dataframe containing only columns ['pnum', 'performance', 'inv_num']
df2_raw = pd.read_csv(input_datafile)
df2 = df2_raw.drop(df2_raw.columns[[2, 3, 5, 6]], axis=1)
# Split the strings of 'inv_num' column -> creates list of strings
df2['inv_num'] = df2_raw['inv_num'].str.split(';')
# Sort by pnum to track moves by time
df2.sort(['pnum'], ascending=True, inplace=True)


# Split col with list of inv_num into seperate/new columns
df2_stretch = pd.concat([df2_raw.firm, df2_raw.pnum,
                         df2_raw.inv_num.apply(lambda y: pd.Series(y.split(';')))],
                        axis=1)

# Split up the inv_num in lists into seperate columns
# arg: id_vars -cols not to 'un-pivot'
# arg: value_vars -names of the new cols created in the stretched df
#       = length of list in original in_num list
df2_long = pd.melt(df2_stretch,
                   id_vars=['pnum', 'firm'],
                   value_vars=range(df2.inv_num.map(lambda x: len(x)).max()),
                   value_name='inv_num')
df2_long = df2_long.drop('variable', axis=1)
df2_sorted = df2_long.sort(['inv_num', 'pnum', 'firm'], ascending=[1, 1, 1])
# Create new column with list of firms
df2_sorted['employer'] = [[x] for x in df2_sorted.firm]


# What companies received the moving inventors

# Create set of inventor - firm moves
df2_firms = df2_sorted.groupby('inv_num')['employer'].sum().reset_index()
df2_firms.columns = ['inv_num', 'employer']

# Number of different firms an inventor has worked for
df2_firms['num_of_employer'] = [len(set(x)) for x in df2_firms.employer]
# Remove duplicate firms
df2_firms.employer = df2_firms.employer.apply(lambda x: pd.unique(x))
# List of new employers i.e. receiving firms
df2_firms['new_employer'] = df2_firms.employer.apply(lambda x: x[1:len(x)])


# Find the moves: inventor ->firm
# Loop through DataFrame to find the firms that received the mobile inventors
df2_moved = df2_firms[(df2_firms.num_of_employer > 1)].drop('employer', axis=1)

inventors = df2_moved.inv_num
firms = df2_moved.new_employer

invs = []
receiving_firm = []
for f in range(len(firms)):
    x = firms.iloc[f]
    inv = inventors.iloc[f]
    for y in x:
        invs.append(inv)
        receiving_firm.append(y)

df_mobile_inv = pd.DataFrame({'mob_inv': invs, 'firm': receiving_firm})

# Create list of all firms to all inventors
df_firms = pd.unique(df2_sorted.firm)
df_inv = pd.unique(df2_sorted.inv_num)

firmlist = []
invlist = []

for firm in df_firms:
    for inv in df_inv:
        firmlist.append(firm)
        invlist.append(inv)


# Create df to output; firm to inventor and binary mobility variable
mob_df = pd.DataFrame({'firm': firmlist, 'inv_num': invlist})
mob_df = mob_df.merge(df_mobile_inv,
                      how='left', left_on=['firm', 'inv_num'],
                      right_on=['firm', 'mob_inv'])

# Create binary variable/dataframe and concatenate to original
mob_df['receiving_firm'] = pd.notnull(mob_df.mob_inv)
just_dummies = pd.get_dummies(mob_df['receiving_firm'])
mob_output = pd.concat([mob_df, just_dummies], axis=1)
mob_output.drop(['receiving_firm', 'mob_inv', False], inplace=True, axis=1)
mob_output.columns = ['firm', 'inv_num', 'receiving_firm']

mob_output = mob_output.groupby('firm')['receiving_firm'].sum().reset_index()


# Joining dataframes to export as csv
output_df1b = pd.merge(mob_output, firm_df, left_on='firm',
                       right_on='firm', how='left')
output_df1b.to_csv(open('parsed_data_1b.csv', 'wb'), index=False)
