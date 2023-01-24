# only read parsed leafspine report

import csv
import re
from os.path import exists
import sys

filename = sys.argv[1]
mstart = int(sys.argv[2])
mend = int(sys.argv[3])

numsw = 80
mstep = mend - mstart

if not exists(filename):
    print("File not found")

for window_start in range(mstart, mend, mstep):
    window_end = window_start + mstep
    #print("from " + str(window_start) + " to " + str(window_end) + ":")

    networkutil_lower = 0
    networkutil_upper = 0
    with open(filename,'r') as fd:
	rd = csv.reader(fd, delimiter="\t", quotechar='"')
	linecount = 0
	for row in rd:
	    linecount += 1
	    start = float(row[0])
	    duration = float(row[1])
	    end = start+duration
	    size = int(row[2])

	    linkcount = 0
	    for i in range(3, len(row)):
		m = re.search(r"(.*)=(.*)",row[i])
		if m:
		    linkcount += 1

	    if (start >= window_start and end < window_end) or (start<window_start and end>=window_end):
		networkutil_lower += size*linkcount
	    if (start >= window_start and start < window_end) or (end >= window_start and end < window_end) or (start<window_start and end>=window_end):
		networkutil_upper += size*linkcount

    # only non-zero entries are taken into consideration
    networkcapacity = mstep * 2748776448.0
    print(str(networkutil_lower/networkcapacity)+" "+str(networkutil_upper/networkcapacity))
