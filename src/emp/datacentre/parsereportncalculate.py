import csv
import re

onlink = True
targetsrcsw = 36
targetdstsw = 52
# targetsrcswlist = [25,36,37,70]
mstart = 0
mend = 350
n99fct = 26.693

sizesum = 0
sizecount = 0
with open("fct_results_0311report/report_2",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    # isqueue = False
    shouldqueue = False
    size = -1
    for row in rd:
        if row[0][:3] == "FCT":
            # if isqueue:
            #     print("*****Error: the line below FCT is not queue (1)")
            #     exit()
            # isqueue = True

            if shouldqueue:
                print("*****Error: shouldqueue is not cleared")
                exit()

            this_fct = float(row[2])
            this_start = float(row[3])
            if mstart<=this_start and this_start<mend and this_fct>n99fct:
                # print("this_start="+str(this_start)+",this_fct="+str(this_fct))
                shouldqueue = True
                size = int(row[1])

            # size can be -1 here if the previous path is not through the target link
            # if size != -1:
            #     print("*****Error: size is not cleared")
            
        if row[0][:5] == "queue" and shouldqueue:
            # if not isqueue:
            #     print("*****Error: the line below FCT is not queue (2)")
            #     exit()
            # isqueue = False
            shouldqueue = False
            shouldinclude = False
            for i in range(1,len(row)-2,2):
                m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
                matched = m.groups()
                if matched[0] == 'SW' and matched[2] == 'SW':
                    srcsw = int(matched[1])
                    dstsw = int(matched[3])
                    # print("srcsw="+str(srcsw)+",dstsw="+str(dstsw))

                    if onlink:
                        if srcsw == targetsrcsw and dstsw == targetdstsw:
                            shouldinclude = True
                    else:
                        if srcsw in targetsrcswlist and dstsw != targetdstsw:
                            shouldinclude = True

            if onlink:
                if shouldinclude:
                    if size == -1:
                        print("*****Error: size is not defined")
                        exit()
                    sizesum += size
                    sizecount += 1
                    size = -1
            else:
                if not shouldinclude:
                    if size == -1:
                        print("*****Error: size is not defined")
                        exit()
                    sizesum += size
                    sizecount += 1
                    size = -1

print("sizesum = " + str(sizesum))
print("sizecount = " + str(sizecount))
print("average size = " + str(sizesum/sizecount))
