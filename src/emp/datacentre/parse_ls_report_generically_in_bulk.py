import csv
import re
from os.path import exists

#for mv in range(100,801,100):
for mv in range(1,3):
    for rv in range(1,2):
        print("m=" + str(mv) + ", r=" + str(rv))
        inputfilename = "fct_results_0530t500clusterblsreport/m" + str(mv) + "r" + str(rv)
        outputfilename = "fct_results_0530t500clusterblsreport/pm" +str(mv) + "r" + str(rv)
	if not exists(inputfilename):
	    print("File not found")
	    continue

        expect_queue = False
        expect_fct = True
        f = open(outputfilename,'w')
        with open(inputfilename,'r') as fd:
            rd = csv.reader(fd, delimiter=" ", quotechar='"')
            for row in rd:
                if row[0][:5] != "queue" and row[0][:3] != "FCT":
                    continue
                if row[0][:5] == "queue":
                    if (not expect_queue) or expect_fct:
                        print("*****Error: queue")
                        exit()
                    expect_fct = True
                    expect_queue = False

                    for i in range(1,len(row)-2,2):
                        m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
                        matched = m.groups()
                        if matched[0] != 'SRC' and matched[2] != 'DST':
                            f.write(matched[0]+matched[1] + "=" + matched[2]+matched[3] + "\t")
                    f.write("\n")
                if row[0][:3] == "FCT":
                    if (not expect_fct) or expect_queue:
                        print("*****Error: FCT")
                        exit()
                    expect_fct = False
                    expect_queue = True

                    size = row[1]
                    fct = row[2]
                    start = row[3]
                    actual_size = row[4]
                    f.write(start + "\t" + fct + "\t" + size + "\t" + actual_size + "\t")      
        f.close()  
