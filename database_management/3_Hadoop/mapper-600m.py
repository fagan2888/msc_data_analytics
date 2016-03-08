#!/usr/bin/env python
 
from itertools import groupby
import sys

datum = []

for line in sys.stdin:
  line = line.strip()
  parts = line.split('\t')
  try:
    count = int(parts[3].strip())
    song = parts[1].strip().lower()
    if song:
      datum.append((song, count))
  except ValueError:
    pass

for song, group in groupby(datum, lambda x: x[0]):
  total_count = 0
  for data in group:
    total_count += data[1]

  if total_count > 600000000:
    print song, total_count

