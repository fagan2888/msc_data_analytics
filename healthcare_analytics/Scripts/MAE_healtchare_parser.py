# -*- coding: utf-8 -*-
"""
Created on Thu Mar 31 10:04:59 2016

@author: mariaathena
"""

import pandas as pd

# Filepaths
datafile = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1602 Healthcare & Medical Analytics/Assignment (individual)/Data (csv)/raw_readmission_data.csv'
#test_data = '/Users/mariaathena/Dropbox (Personal)/00 Imperial College/1602 Healthcare & Medical Analytics/Assignment (individual)/Data (csv)/test_data.csv'

df = pd.read_csv(datafile)
#df = pd.read_csv(test_data)

column_names = list(df.columns.values)


# Helper functions

# Create AgeGroup Variable from 'age' variable
def agegroup(age):
    child_young = ['[1-10]', '[10-20]', '[20-30]']
    adult = ['[30-40]', '[40-50]', '[50-60]', '[60-70]']
#    adult_over50 = ['[50-60]', '[60-70]']
    elderly = ['[70-80]', '[80-90]', '[90-100]']

    if age in child_young:
        return 'child_young'
    elif age in adult:
        return 'adult'
#    elif age in adult_over50:
#        return 'adult_over50'
    elif age in elderly:
        return 'elderly'
    else:
        return 'unknown'

# Group minority races in the 'race' variable
def other_races(the_race):
    other = ['?', 'Hispanic', 'Asian']
    
    if the_race in other:
        return 'Other'
    else:
        return the_race
        

# Group the two readmissions variable for the final visualisations
def under_30(sickies):
    if sickies == 1:
        return 'readmitted_under30'
    else:
        return None

    
def over_30(sickos):
    if sickos == 1:
        return 'readmitted_over30'
    else:
        return None


# Create Patient Profile

# Create dummy variable columns for gender field
gender_df = pd.concat([df['Patient ID'], pd.get_dummies(df.gender, prefix='Gender')], axis=1)

# Clean age variable up
df.age = df.age.apply(lambda x: agegroup(x))
# Create dummy variable columns for age_group field
age_df = pd.concat([df['Patient ID'], pd.get_dummies(df.age, prefix='Age')], axis=1)

# Clean age variable up
df.race = df.race.apply(lambda x: other_races(x))
# Create dummy variable columns for race field
race_df = pd.concat([df['Patient ID'], pd.get_dummies(df.race, prefix='Race')], axis=1)

# Concatenate profile variables dataframes
#profile_df = pd.concat([gender_df, age_df, race_df], axis=1)
profile_df = gender_df.merge(age_df, 
                             on='Patient ID').merge(race_df, on='Patient ID')


# For the visual representation create column combining the readmissions vars
df['readmitted_under30'] = df.readmission_lessthan30.apply(lambda x: under_30(x))
df['readmitted_over30'] = df.readmission_morethan30.apply(lambda x: over_30(x))
df['readmissions'] = df[['readmitted_under30', 'readmitted_over30']].fillna('').sum(axis=1)

#readmitted_df = pd.concat([df['Patient ID'], pd.get_dummies(df.readmissions, prefix='Readmitted')], axis=1)

df['readmitted'] = df[['readmission_lessthan30', 'readmission_morethan30']].sum(axis=1)

df.drop(['readmitted_under30', 'readmitted_over30'],  axis=1, inplace=True)

# Joining dataframes to export as csv
output_df = pd.merge(df, profile_df,
                      left_on='Patient ID',
                      right_on='Patient ID', how='outer')

output_df.to_csv(open('parsed_healthcare_data.csv', 'wb'), index=False)
