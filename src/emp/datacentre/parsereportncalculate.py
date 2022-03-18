import csv
import re

targetsrcsw = 25
targetdstsw = 52

sizesum = 0
sizecount = 0
with open("output",'r') as fd:
    rd = csv.reader(fd, delimiter=" ", quotechar='"')
    isqueue = False
    size = -1
    for row in rd:
        if row[0][:3] == "FCT":
            if isqueue:
                print("*****Error: the line below FCT is not queue (1)")
                exit()
            isqueue = True
            # size can be -1 here if the previous path is not through the target link
            # if size != -1:
            #     print("*****Error: size is not cleared")
            size = int(row[1])
        if row[0][:5] == "queue":
            if not isqueue:
                print("*****Error: the line below FCT is not queue (2)")
                exit()
            isqueue = False
            for i in range(1,len(row)-2,2):
                m = re.search(r"queue\(.*\)([A-Z]+)_(\d+)-([A-Z]+)_(\d+)",row[i])
                matched = m.groups()
                if matched[0] == 'SW' and matched[2] == 'SW':
                    srcsw = int(matched[1])
                    dstsw = int(matched[3])
                    if srcsw == targetsrcsw and dstsw == targetdstsw:
                        if size == -1:
                            print("*****Error: size is not defined")
                            exit()
                        sizesum += size
                        sizecount += 1
                        size = -1

print("sizesum = " + str(sizesum))
print("sizecount = " + str(sizecount))
print("average size = " + str(sizesum/sizecount))