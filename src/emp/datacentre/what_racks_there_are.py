import csv
import re

filename = "fct_results_0427t200016to4lsreport/m8r1"

rack_set = set()
with open(filename,'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    for row in rd:
        if row[0][:5] == "queue":
            for i in range(1,len(row)-2,2):
                m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
                matched = m.groups()
                if matched[0] != 'SRC' and matched[2] != 'DST':
                    rack_set.add(matched[0]+matched[1])
                    rack_set.add(matched[2]+matched[3])

print(rack_set)   
