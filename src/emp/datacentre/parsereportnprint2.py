import csv
import re

mstart = 154
mend = 164

with open("fct_results_0320report/su3_report",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    # isqueue = False
    shouldprint = False
    for row in rd:
        if row[0][:3] == "FCT":
            # if isqueue:
            #     print("*****Error: the line below FCT is not queue (1)")
            #     exit()
            # isqueue = True

            if shouldprint:
                print("*****Error: shouldprint is not cleared")
                exit()

            this_size = int(row[1])
            this_fct = float(row[2])
            this_start = float(row[3])
            if mstart<=this_start and this_start<mend:
                print("flow starts at "+str(this_start) + " with fct "+str(this_fct)+" of size "+str(this_size))
                shouldprint = True
            
        if row[0][:5] == "queue" and shouldprint:
            # if not isqueue:
            #     print("*****Error: the line below FCT is not queue (2)")
            #     exit()
            # isqueue = False
            shouldprint = False
            for i in range(1,len(row)-2,2):
                m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
                matched = m.groups()
                if matched[0] == 'SW' and matched[2] == 'SW':
                    srcsw = int(matched[1])
                    dstsw = int(matched[3])
                    print("link"+str(srcsw)+"-"+str(dstsw)+" ")
