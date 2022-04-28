# only read parsed leafspine report

import csv
import re

numsw = 80
mstart = 700
mend = 1900
mstep = 200
k = 10
filename = "parsed_text.txt"

def print_top_k_items(matrix, size, k):
    list_for_matrix = []
    for i in range(size):
        for j in range(size):
            list_for_matrix.append(matrix[i][j])
    list_for_matrix.sort(reverse=True)

    threshold = list_for_matrix[k]
    for i in range(size):
        for j in range(size):
            if matrix[i][j]>threshold:
                print("link" + str(i) + "=" + str(j) + ": " + str(matrix[i][j]))

for window_start in range(mstart, mend, mstep):
    window_end = window_start + mstep
    print("from " + str(window_start) + " to " + str(window_end) + ":")

    linkdemand_expected_upper = [[0 for x in range(numsw)] for y in range(numsw)]
    linkdemand_real_upper = [[0 for x in range(numsw)] for y in range(numsw)]
    linkdemand_expected_lower = [[0 for x in range(numsw)] for y in range(numsw)]
    linkdemand_real_lower = [[0 for x in range(numsw)] for y in range(numsw)]
    flow_size = 0
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
                    if link_name == "SW":
                        link_number += 16
                    link_name2 = matched[1]
                    link_type2 = link_name2[:2]
                    link_number2 = int(link_name2[2:])
                    if link_name2 == "SW":
                        link_number2 += 16
                    link = tuple([link_number, link_number2])
                    link_set.add(link)

            for link in link_set:
                src = link[0]
                dst = link[1]
                if start >= window_start and end < window_end:
                    linkdemand_expected_lower[src][dst] += size
                    linkdemand_real_lower[src][dst] += actual_size
                if (start >= window_start and start < window_end) or (end >= window_start and end < window_end):
                    linkdemand_expected_upper[src][dst] += size
                    linkdemand_real_upper[src][dst] += actual_size              

    linkcapacity = mstep * 1342176.0
    for i in range(numsw):
        for j in range(numsw):
            linkdemand_expected_lower[i][j] = linkdemand_expected_lower[i][j]/linkcapacity  
            linkdemand_real_lower[i][j] = linkdemand_real_lower[i][j]/linkcapacity  
            linkdemand_expected_upper[i][j] = linkdemand_expected_upper[i][j]/linkcapacity  
            linkdemand_real_upper[i][j] = linkdemand_real_upper[i][j]/linkcapacity   

    print("expected lower:")
    print_top_k_items(linkdemand_expected_lower, numsw, k)
    print("real lower:")
    print_top_k_items(linkdemand_real_lower, numsw, k)
    print("expected upper:")
    print_top_k_items(linkdemand_expected_upper, numsw, k)
    print("real upper:")
    print_top_k_items(linkdemand_real_upper, numsw, k)
