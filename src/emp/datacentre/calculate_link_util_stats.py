# only read parsed leafspine report

import csv
import re
import sys

routing=sys.argv[1]
multstr=sys.argv[2]

numsw = 80
mstart = 50
mend = 150
mstep = 100
filename = "fct_results_dringa2areport/p"+routing+"_"+multstr


for window_start in range(mstart, mend, mstep):
    window_end = window_start + mstep
    print("from " + str(window_start) + " to " + str(window_end) + ":")

    # linkdemand_expected_upper = [[0 for x in range(numsw)] for y in range(numsw)]
    linkdemand_real_upper = [[0 for x in range(numsw)] for y in range(numsw)]
    # linkdemand_expected_lower = [[0 for x in range(numsw)] for y in range(numsw)]
    linkdemand_real_lower = [[0 for x in range(numsw)] for y in range(numsw)]
    with open(filename,'r') as fd:
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        linecount = 0
        for row in rd:
            start = float(row[0])
            duration = float(row[1])
            end = start+duration
            size = int(row[2])
            actual_size = int(row[3])

            link_set = set()
            for i in range(4, len(row)):
                m = re.search(r"(.*)=(.*)",row[i])
                if m:
                    matched = m.groups()
                    link_name = matched[0]
                    link_type = link_name[:2]
                    link_number = int(link_name[2:])
                    if link_type == "LS":
                        link_number += 16
                    link_name2 = matched[1]
                    link_type2 = link_name2[:2]
                    link_number2 = int(link_name2[2:])
                    if link_type2 == "LS":
                        link_number2 += 16
                    link = tuple([link_number, link_number2])
                    link_set.add(link)

            for link in link_set:
                src = link[0]
                dst = link[1]
                if start >= window_start and end < window_end:
                    # linkdemand_expected_lower[src][dst] += size
                    linkdemand_real_lower[src][dst] += actual_size
                if (start >= window_start and start < window_end) or (end >= window_start and end < window_end):
                    # linkdemand_expected_upper[src][dst] += size
                    linkdemand_real_upper[src][dst] += actual_size              

    # only non-zero entries are taken into consideration
    # linkdemand_expected_upper_arr = []
    linkdemand_real_upper_arr = []
    # linkdemand_expected_lower_arr = []
    linkdemand_real_lower_arr = []
    linkcapacity = mstep * 1342176.0

    for i in range(numsw):
        for j in range(numsw):
            # linkdemand_expected_lower_arr.append(linkdemand_expected_lower[i][j]/linkcapacity)
            linkutil_real_lower = linkdemand_real_lower[i][j]/linkcapacity
            if linkutil_real_lower > 0:
                linkdemand_real_lower_arr.append(linkutil_real_lower) 
            # linkdemand_expected_upper_arr.append(linkdemand_expected_upper[i][j]/linkcapacity)  
            linktuil_real_upper = linkdemand_real_upper[i][j]/linkcapacity
            if linktuil_real_upper > 0:
                linkdemand_real_upper_arr.append(linktuil_real_upper)   

    num_nz_links = len(linkdemand_real_lower_arr)
    print("real lower bound - average/median/n99/max link util:")
    print(str(sum(linkdemand_real_lower_arr)/num_nz_links))
    linkdemand_real_lower_arr.sort()
    median_index = int(num_nz_links/2)
    n99_index = int(num_nz_links*0.99)
    print(str(linkdemand_real_lower_arr[median_index]))
    print(str(linkdemand_real_lower_arr[n99_index]))      
    print(str(linkdemand_real_lower_arr[num_nz_links-1]))
    print("real upper bound - average/median/n99/max link util:")
    print(str(sum(linkdemand_real_upper_arr)/num_nz_links))
    linkdemand_real_upper_arr.sort()
    print(str(linkdemand_real_upper_arr[median_index]))
    print(str(linkdemand_real_upper_arr[n99_index]))      
    print(str(linkdemand_real_upper_arr[num_nz_links-1]))
