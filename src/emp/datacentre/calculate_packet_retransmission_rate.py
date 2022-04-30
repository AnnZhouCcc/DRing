# only read parsed leafspine report

import csv
import re

numsw = 80
should_print = True
filename = "fct_results_0428t2000r2rlsreport/pm50r1"

for i in range(1):
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
            size = float(row[2])
            actual_size = float(row[3])

            num_flows += 1
            sum_traffic_expected += size
            sum_traffic_real += actual_size
            rr = (actual_size-size)/size
            retransmission.append(rr)
            if should_print and rr>=1:
            	print(row)

    print("overall retransmission\t" + str((sum_traffic_real-sum_traffic_expected)/sum_traffic_expected))    
    print("average retransmission\t" + str(sum(retransmission)/num_flows))
    retransmission.sort()
    median_index = int(num_flows/2)
    n99_index = int(num_flows*0.99)
    print("median retransmission\t" + str(retransmission[median_index]))
    print("n99 retransmission\t" + str(retransmission[n99_index]))      
    print("max retransmission\t" + str(retransmission[num_flows-1]))      
