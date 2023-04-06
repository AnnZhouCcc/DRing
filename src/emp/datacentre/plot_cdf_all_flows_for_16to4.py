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


filelist = ["plot_cdf_16to4-1/dring_su3_lpdbr_23_0_0_640_0","rediscover_rrg_su3_16to4-1_lpdbr/23_0_0_640_0","rediscover_leafspine_ecmp_16to4-1_equal/14_5_10_640_0","plot_cdf_16to4-1/dring_su3_lpdbr_14_5_10_640_0","plot_cdf_16to4-1/rrg_su3_lpdbr_14_5_10_640_0","plot_cdf_16to4-1/leafspine_ecmp_equal_7_0_0_640_0","plot_cdf_16to4-1/dring_su3_lpdbr_7_0_0_640_0","plot_cdf_16to4-1/rrg_su3_lpdbr_7_0_0_640_0"]
colorlist=['black','gray','red','orange','pink','blue','green','purple']
labellist=['high-dring-su3-sob','high-rrg-su3-sob','medium-ls-ecmp-ob','medium-dring-su3-sob','medium-rrg-su3-sob','low-ls-ecmp-ob','low-dring-su3-sob','low-rrg-su3-sob']
    
for i in range(len(filelist)):
    filename = filelist[i]
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

plt.title('CDF of all flows 16to4-1') 

plt.savefig("cdf_16to4-1.pdf") 
