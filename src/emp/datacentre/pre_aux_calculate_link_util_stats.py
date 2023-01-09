# only read parsed leafspine report

import csv
import re
import sys

filename=sys.argv[1]
mstart = int(sys.argv[2])
mend = int(sys.argv[3])

numsw = 80
mstep = mend - mstart

for window_start in range(mstart, mend, mstep):
    window_end = window_start + mstep
    #print("from " + str(window_start) + " to " + str(window_end) + ":")

    linkdemand_expected_upper = [[0 for x in range(numsw)] for y in range(numsw)]
    linkdemand_expected_lower = [[0 for x in range(numsw)] for y in range(numsw)]
    with open(filename,'r') as fd:
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        linecount = 0
        for row in rd:
            start = float(row[0])
            duration = float(row[1])
            end = start+duration
            size = int(row[2])

            link_set = set()
            for i in range(3, len(row)):
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
                    linkdemand_expected_lower[src][dst] += size
                    linkdemand_expected_upper[src][dst] += size
                elif (start >= window_start and start < window_end) and (end >= window_end):
                    linkdemand_expected_upper[src][dst] += size
                elif (start <= window_start) and (window_start <= end and end <= window_end):
                    linkdemand_expected_upper[src][dst] += size
                elif (start <= window_start) and (window_end <= end):
                    linkdemand_expected_lower[src][dst] += size
                    linkdemand_expected_upper[src][dst] += size

    # only non-zero entries are taken into consideration
    linkdemand_expected_upper_arr = []
    linkdemand_expected_lower_arr = []
    linkcapacity = mstep * 1342176.0

    for i in range(numsw):
        for j in range(numsw):
            linkutil_expected_lower = linkdemand_expected_lower[i][j]/linkcapacity
            if linkutil_expected_lower > 0:
                linkdemand_expected_lower_arr.append(linkutil_expected_lower) 
                #print("i="+str(i)+",j="+str(j)+": "+str(linkutil_expected_lower))
            linktuil_expected_upper = linkdemand_expected_upper[i][j]/linkcapacity
            if linktuil_expected_upper > 0:
                linkdemand_expected_upper_arr.append(linktuil_expected_upper)   

    num_nz_links = len(linkdemand_expected_lower_arr)
    linkdemand_expected_lower_arr.sort()
    linkdemand_expected_upper_arr.sort()
    print(str(linkdemand_expected_lower_arr[num_nz_links-1])+" "+str(linkdemand_expected_upper_arr[num_nz_links-1]))
    
