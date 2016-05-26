# -*- coding: utf-8 -*-

# Setup - reset and load packages
import pandas as pd
import numpy as np

# Get the data
similarities = pd.read_csv("../data/cleaned/03_similarities.csv")

# Find highest similarity
best_match = pd.DataFrame(similarities.groupby('person')['sim'].max())

