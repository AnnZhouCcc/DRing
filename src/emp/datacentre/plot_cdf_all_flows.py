import matplotlib.pyplot as plt
import numpy as np


def values_to_cdf(values):
    cdf_list = []
    values.sort()
    count = 0
    for v in values:
        count += 1
        cdf_list.append(count / len(values))
    return cdf_list


fileprefix = "rediscover_"
filesuffixlist = ["leafspine_ecmp_16to4-1_equal/14_5_10_640_0","rrg_su3_16to4-1_lpdbr/23_0_0_640_0"]
colorlist=['red','blue']
labellist=['leafspine,ecmp,oblivious','rrg,su3,semi-oblivious']
    
for i in range(len(filesuffixlist)):
    filename = fileprefix + filesuffixlist[i]
    data = list()
    with open(filename) as f:
        for line in f:
            tokens = line.split()
            if tokens[0] != "FCT": continue
            fct=float(tokens[2])
            data.append(fct)

    plt.plot(data,values_to_cdf(data),label=labellist[i],alpha=0.8, color=colorlist[i])

plt.xlim([0,5])
plt.legend(loc="lower right")
plt.xlabel('fct') 
plt.ylabel('%')

plt.title('CDF of all FCTs') 

plt.savefig("test_cdf.pdf") 
