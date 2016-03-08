#!/usr/bin/env python
 
import sys

for line in sys.stdin:
    line = line.strip()
    parts = line.split('\t')
    artist = parts[2].strip().lower()
    if artist == "u2":
        print "U2"
