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


fileprefix = "rediscover_rrg_su3_clustera_equal/12_0_0_200_"
colorslist = ['red','purple','green','orange','blue','brown','pink','gray','cyan','yellow']

for i in range(10):
    filename = fileprefix+str(i)
    data = list()
    
    with open(filename) as f:
        for line in f:
            tokens = line.split()
            if tokens[0] != "FCT": continue
            fct=float(tokens[2])
            data.append(fct)

    plt.plot(data,values_to_cdf(data),label=i,alpha=0.8, color=colorslist[i])

plt.xlim([0,10])
plt.xlabel('fct') 
plt.ylabel('%')

plt.title('CDF of all FCTs') 

plt.savefig("test_cdf.pdf") 
