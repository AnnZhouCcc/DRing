# only read parsed leafspine report

import csv
import re

numsw = 80
mstart = 100
mend = 1900
mstep = 1800


for mv in range(50,601,50):
    for rv in range(1,6):
        print("m=" + str(mv) + ", r=" + str(rv))
        filename = "fct_results_0428t2000r2rlsreport/pm" + str(mv) + "r" + str(rv)
        
        for wstart in range(mstart, mend, mstep):
            wend = wstart +  mstep
            print("from " + str(wstart) + " to " + str(wend) + ":")

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

                    # we only do a lower bound here
                    if start>=wstart and end<wend:
                        num_flows += 1
                        sum_traffic_expected += size
                        sum_traffic_real += actual_size
                        rr = (actual_size-size)/size
                        retransmission.append(rr)

            print("overall/average/median/n99/max retransmission:")
            print(str((sum_traffic_real-sum_traffic_expected)/sum_traffic_expected))    
            print(str(sum(retransmission)/num_flows))
            retransmission.sort()
            median_index = int(num_flows/2)
            n99_index = int(num_flows*0.99)
            print(str(retransmission[median_index]))
            print(str(retransmission[n99_index]))      
            print(str(retransmission[num_flows-1]))      
