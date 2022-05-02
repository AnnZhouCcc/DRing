import csv
import re

m_values = [100,150,250,350,400,450,500,550]
for m in m_values:
    for r in range(1,6):
        inputfilename = "fct_results_0428t2000r2rlsreport/m" + str(m) + "r" + str(r)
        outputfilename = "fct_results_0428t2000r2rlsreport/pm" + str(m) + "r" + str(r)

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
