import csv
import re

threshold = 1000
numsw = 80

linkfreq = [[0 for x in range(numsw)] for y in range(numsw)] 
with open("output",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    linecount = 0
    for row in rd:
        if row[0][:5] != "queue":
	    continue
        linecount += 1
        for i in range(1,len(row)-2,2):
            m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
            matched = m.groups()
            if matched[0] == 'SW' and matched[2] == 'SW':
                srcsw = int(matched[1])
                dstsw = int(matched[3])
                linkfreq[srcsw][dstsw] += 1

print("linecount = "+str(linecount))
for i in range(numsw):
    for j in range(numsw):
        if linkfreq[i][j] > threshold:
            print("link"+str(i)+"-"+str(j)+": "+str(linkfreq[i][j]))
# print("linkfreq of link25-52 = " + str(linkfreq[25][52])) 
           
