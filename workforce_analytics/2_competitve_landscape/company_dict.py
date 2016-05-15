# -*- coding: utf-8 -*-
"""
Created on Thu Feb  4 10:55:04 2016

Workfoce Analytics Lab1 - Company Dictionaries

Data scraped from the web containing US firms' description of their activity
(10k forms). Using this we create dictionaries of frequently used terms to
map what firms are competing with each other.

@author: MariaAthena
"""

import os
import re  # regular expression to specify strings to match
import argparse  # command line tools helper
# import codecs  # for reading unicode files
import pandas as pd
import numpy as np
import nltk
import collections


# RE to match filenames of type:
# ADI_2000.txt
# AFOP_2002.txt
file_match = "(?P<ticker>[A-Z]*)_(?P<years>([0-9]{4}))\.txt"


# Extract nouns from a Python string object
def extract_nouns(txt):

    nouns = []

    # create list of words in a text, taking out punctuations, symbols etc.
    words = nltk.word_tokenize(txt)
    # categorise all words in text with tags
    tags = nltk.pos_tag(words)

    # select all words categorised as nouns
    for word, pos in tags:
        if (pos == 'NN' or pos == 'NNS' or pos == 'NNP' or pos == 'NNPS'):
            nouns.append(word.lower())

    return nouns


# Create list of words occurring too frequently to include in dictionaries
def stop_words(word_list):

    stop_list = []
    counts = collections.Counter(word_list)
    frequency = counts[word] / float(len(word_list))

    for word in word_list:
        single_word_list = word_list.unique()

        if frequency > 0.1:
            stop_list.append(word)

    return (single_word_list, stop_list)


# Calculate the cosine similarity of two vectors
def cosine_sim(vect1, vect2):
    numerator = sum(a*b for a, b in zip(vect1, vect2))
    denom1 = sum(a**2 for a in vect1) ** 0.5
    denom2 = sum(b**2 for b in vect2) ** 0.5
    denom = denom1*denom2
    if not denom:
        cos_sim = 0
    else:
        cos_sim = round(float(numerator)/denom, 3)
    return cos_sim


# Calculate the similarity of two vectors
def similarity(vect1, vect2):
    a = set(vect1)
    b = set(vect2)
    top = len(a & b)
    bottom = len(a | b)
    sim = top / float(bottom)
    return sim


# Extract .txt filenames info and nouns from content into Python dictionary obj
# then output dict to pandas DataFrame
def main(data_folder):

    output_df = pd.DataFrame()
    # params = ['firm', 'year', 'nouns']

    # create empty dict of lists with predefined keys
    output_dict = {'ticker': [], 'years': [], 'firm_nouns': []}

    for root, dirs, filenames in os.walk(data_folder):

        for filename in filenames:
            result = re.match(file_match, filename)

            if result:

                # make the match a dict: {'ticker': 'XXX', 'years': '200X'}
                data = result.groupdict()
                company = result.groupdict()['ticker']
                year = result.groupdict()['years']
                print('Parsing : ' + company + year)  # terminal feedback

                filepath = os.path.join(data_folder, filename)

                with open(filepath) as file:
                    try:
                        text = file.read().replace('\n', '')  # remove new line
                        firm_yr_list = extract_nouns(text)
                        data['firm_nouns'] = firm_yr_list

                    except:
                        pass

                # output_dict: {'firm_yr_list': [...] 'ticker': ['XXX', ], 'years': ['200X',...]}
                output_dict['ticker'].append(company)
                output_dict['years'].append(year)
                output_dict['firm_nouns'].append(firm_yr_list)

        # Put output_dict in pandas df
        output_df = pd.DataFrame(output_dict)

        # Group all nouns from each years by firm
        all_firm_nouns = pd.DataFrame(output_df.groupby('ticker')['firm_nouns'].sum())
        # Create list of this
        firm_list = list(all_firm_nouns['firm_nouns'])

        # List with all nouns from all firms
        (global_list, stop_list) = stop_words(global_list)  # CHECK!
        global_list = [word for word in global_list if word not in stop_list]  # CHECK!

        # remove duplicate and stopwords from firm dictionaries  # CHECK! (incomplete)
        firm_list_unique = []
        for dic in firm_list:
            dic = collections.Counter(dic).keys()
            dic = [word for word in dic if word not in stop_list]
            firm_list_unique.append(dic)

        # Dictionary with 'ticker', 'firm_dict'  # CHECK! (incomplete)
        df1 = pd.DataFrame()

    df1.to_csv(open('Dictionaries.csv', 'wb'), index=False)


# Command line helper prints + add arguments for running script
if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Parse 10k_files')
    parser.add_argument('-i', '--input',
                        dest='data_source',
                        metavar='input folder',
                        help='source folder of the data (default: current folder)',
                        default='.')

    parser.add_argument('-o', '--output',
                        dest='output_file',
                        metavar='output filename',
                        help='output filename (default: Dictionaries.csv)',
                        default='Dictionaries.csv')

    args = parser.parse_args()

    main(args.data_source)
