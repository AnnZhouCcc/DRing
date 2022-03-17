import csv
import re

numsw = 80

linkfreq = [[0 for x in range(numsw)] for y in range(numsw)] 
with open("rank_sample.txt",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    for row in rd:
        for i in range(1,len(row)-2,2):
            m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
            matched = m.groups()
            if matched[0] == 'SW' and matched[2] == 'SW':
                srcsw = int(matched[1])
                dstsw = int(matched[3])
                linkfreq[srcsw][dstsw] += 1

for i in range(numsw):
    for j in range(numsw):
        if linkfreq[i][j] > 0:
            print("link"+str(i)+"-"+str(j)+": "+str(linkfreq[i][j]))
            