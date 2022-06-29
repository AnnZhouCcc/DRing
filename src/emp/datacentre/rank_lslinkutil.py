import csv
import re

threshold = 0.3
numsw = 80
mstart = 1900
mend = 2000
is_lower_bound = False
filename = "fct_results_0427t200016to4lsreport/m8r1"

linkfreq = [[0 for x in range(numsw)] for y in range(numsw)] 
expect_queue = False
expect_fct = True
should_consider = False
flow_size = 0
with open(filename,'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    linecount = 0
    for row in rd:
        linecount += 1
        if row[0][:5] != "queue" and row[0][:3] != "FCT":
	        continue
        if row[0][:5] == "queue":
            if (not expect_queue) or expect_fct:
                print("*****Error: queue")
                exit()
            expect_fct = True
            expect_queue = False

            if should_consider:
                if flow_size == 0:
                    print("*****Error(" + str(linecount) + "): flow_size == 0")
                    exit()
                for i in range(1,len(row)-2,2):
                    m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
                    matched = m.groups()
                    if (matched[0] == 'LS' and matched[2] == 'US') or (matched[0] == 'US' and matched[2] == 'LS'):
                        srcsw = int(matched[1])
                        dstsw = int(matched[3])
                        linkfreq[srcsw][dstsw] += flow_size
                flow_size = 0
                should_consider = False
        if row[0][:3] == "FCT":
            if (not expect_fct) or expect_queue:
                print("*****Error: FCT")
                exit()
            expect_fct = False
            expect_queue = True
            if flow_size != 0:
                print("*****Error: flow_size != 0")
                exit()

            size = int(row[4])
            fct = float(row[2])
            start = float(row[3])
            end = start+fct
            if is_lower_bound:
                if start >= mstart and end < mend:
                    should_consider = True
                    flow_size = size
            else:
                if (start >= mstart and start < mend) or (end >= mstart and end < mend):
                    should_consider = True
                    flow_size = size

linkcapacity = (mend-mstart) * 1342176.0
for i in range(numsw):
    for j in range(numsw):
        linkutil = linkfreq[i][j]/linkcapacity
        if linkutil > threshold:
            print("link"+str(i)+"-"+str(j)+": "+str(linkutil))    
