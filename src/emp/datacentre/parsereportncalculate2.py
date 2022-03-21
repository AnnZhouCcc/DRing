import csv
import re

mstart = 271
mend = 275

flowcountarr = [0,0,0,0,0]
flowsizearr = [0,0,0,0,0]
with open("fct_results_0320report/maxdisjoint_report",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    # isqueue = False
    for row in rd:
        if row[0][:3] == "FCT":
            # if isqueue:
            #     print("*****Error: the line below FCT is not queue (1)")
            #     exit()
            # isqueue = True

            this_start = float(row[3])
            this_size = int(row[1])
            if mstart<=this_start and this_start<mend+1:
                whichcell = int(this_start-mstart)
                flowcountarr[whichcell] += 1
                flowsizearr[whichcell] += this_size

print(flowcountarr)
print(flowsizearr)
