# only read parsed leafspine report

import csv
import re

numsw = 80
mstart = 100
mend = 2000
mstep = 1900
filename = "fct_results_0428t2000r2rlsreport/m300r1"

for window_start in range(mstart, mend, mstep):
    window_end = window_start + mstep
    print("from " + str(window_start) + " to " + str(window_end) + ":")

    retransmission = []
    sum_traffic_expected = 0
    sum_traffic_real = 0 
    num_flows = 0
    with open(filename,'r') as fd:
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        for row in rd:
            start = float(row[0])
            duration = float(row[1])
            end = start+duration
            size = int(row[2])
            actual_size = int(row[3])

            num_flows += 1
            sum_traffic_expected += size
            sum_traffic_real += actual_size
            retransmission.append((actual_size-size)/size)

    print("overall retransmission\t" + str((sum_traffic_real-sum_traffic_expected)/sum_traffic_expected))    
    print("average retransmission\t" + str(sum(retransmission)/num_flows))
    retransmission.sort()
    median_index = int(num_flows/2)
    n99_index = int(num_flows*0.99)
    print("median retransmission\t" + str(retransmission[median_index]))
    print("n99 retransmission\t" + str(retransmission[n99_index]))      
