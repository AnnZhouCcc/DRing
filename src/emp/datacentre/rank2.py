import csv
import re

numsw = 80

sumstart = 0
countstart = 0
with open("rank_sample.txt",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    for row in rd:
        start = int(row[0])
        sumstart += start
        countstart += 1

print("Average start time = " + str(sumstart/countstart))
            