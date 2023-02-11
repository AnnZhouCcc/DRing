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


filelist = ["rediscover_rrg_su3_a2a_lppbr/0_78_100_200_0","plot_cdf_a2a/leafspine_ecmp_equal_0_63_100_200_0","rediscover_dring_su3_a2a_lpdbr/0_63_100_200_0","plot_cdf_a2a/rrg_su3_lpdbr_0_63_100_200_0","plot_cdf_a2a/leafspine_ecmp_equal_0_3_10_200_0","plot_cdf_a2a/dring_su3_lpdbr_0_3_10_200_0","plot_cdf_a2a/rrg_su3_lpdbr_0_3_10_200_0"]
colorlist=['gray','red','orange','pink','blue','green','purple']
labellist=['high-rrg-su3-sob','medium-ls-ecmp-ob','medium-dring-su3-sob','medium-rrg-su3-sob','low-ls-ecmp-ob','low-dring-su3-sob','low-rrg-su3-sob']
    
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

plt.title('CDF of all flows all-to-all') 

plt.savefig("cdf_a2a.pdf") 
