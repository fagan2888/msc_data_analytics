# -*- coding: utf-8 -*-
"""
Created on Wed Feb 17 21:46:24 2016

Worforce Analytics - Part Ia

@author: MariaAthena
"""

import itertools
import pandas as pd
import numpy as np
from collections import Counter


filename = 'D3_patent_data.csv'

# Create dataframe containing only columns ['pnum', 'performance', 'inv_num']
df = pd.read_csv(filename)
df.drop(df.columns[[2, 5, 6]], axis=1, inplace=True)
# Split the strings of 'inv_num' column -> creates list of strings
df['inv_num'] = df['inv_num'].str.split(';')
# To increase efficiency, take out single inventor patents
df = df[df['inv_num'].map(len) > 1]


# Create dict of format {(firm, pnum): [inv_num]}
dict_teams = dict()
for obj in range(len(df)):
    pnum_key = (df.iloc[obj, 1], df.iloc[obj, 0])
    inv_num_value = df.iloc[obj, 3]
    dict_teams.setdefault(pnum_key, [])
    dict_teams[pnum_key] = inv_num_value


# Count of how many times each inventor appears on a patent
all_teams = list(df['inv_num'])  # nested list of teams
everyone = list(itertools.chain(*all_teams))  # flatten the nested list

# Create list of unique of inventors
inventors = []
for inv in everyone:
    if inv not in inventors:
        inventors.append(inv)
count = Counter(inventors)


# Calculate the similarity of two vectors
def similarity(vect1, vect2):
    a = set(vect1)
    b = set(vect2)
    top = len(a & b)
    bottom = len(a | b)
    sim = top / float(bottom)
    return sim


# Comparing number of times inventors worked together on patent
# i.e. team similarity
t1 = []
t2 = []
similarities = []
i = 0
for key1, team1 in dict_teams.items():
    j = 0
    t1_vect = dict_teams.items()[i][1]
    print 'i: ', i
    for key2, team2 in dict_teams.items():
        # To increase efficiency:
        # 1. We only need half of the symmetrical matrix
        if j > i:
            break

        # 2. Only look for collaboration within the same firm
        elif key1[0] != key2[0]:
            break

        t2_vect = dict_teams.items()[j][1]

        t1.append(dict_teams.items()[i][0][1])
        t2.append(dict_teams.items()[j][0][1])
        similarities.append(similarity(t1_vect, t2_vect))
        j += 1
    i += 1

sims_dict = {'team1': t1,
             'team2': t2,
             'similarity': similarities}

sims_data = pd.DataFrame(sims_dict)
sims_data = sims_data[['team1', 'team2', 'similarity']]  # reorder cols

# Remove rows where 'team1' = 'team2' i.e. == 1
sims_data = sims_data[sims_data['similarity'] != 1]

# create DataFrame to join on original DF with average similarity of team1
avg_sim_df = sims_data.groupby('team1')['similarity'].aggregate(np.mean).reset_index()
avg_sim_df.columns = ['pnum', 'avg_similarity']  # rename cols

# inner join on dataframes to export as csv
# Join all data together
output_df1a = pd.merge(df, avg_sim_df,
                       left_on='pnum', right_on='pnum', how='left')
output_df1a.to_csv(open('parsed_data_1a.csv', 'wb'), index=False)
