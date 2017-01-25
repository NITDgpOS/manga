#!/usr/bin/env python

import os
import sys

# Gets the index page of mangareader.net

os.system("wget -O index.html -o log.txt www.mangareader.net")
os.remove("log.txt")

# Open the index page on Google Chrome or Firefox according to the users choice

if "-f" in sys.argv:
    os.system("firefox index.html")
else:
    os.system("google-chrome-stable index.html")
