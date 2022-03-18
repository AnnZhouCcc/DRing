import csv
import re

sumstart = 0
countstart = 0
with open("output",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    for row in rd:
        start = float(row[0])
        sumstart += start
        countstart += 1

print("Average start time = " + str(sumstart/countstart))
            
