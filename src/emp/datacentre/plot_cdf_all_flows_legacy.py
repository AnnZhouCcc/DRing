import matplotlib.pyplot as plt
import numpy as np

filename = "rediscover_rrg_su3_clustera_equal/12_0_0_200_0"
data = list()

with open(filename) as f:
    for line in f:
        tokens = line.split()
        if tokens[0] != "FCT": continue
        fct=float(tokens[2])
        if fct<1:
            data.append(fct)

plt.hist(data, weights=np.ones(len(data)) / len(data), cumulative=True, label='CDF',
         histtype='step', alpha=0.8, color='k')

plt.xlabel('fct') 
plt.ylabel('%')

plt.title('CDF of all FCTs') 

plt.savefig("test_cdf.pdf") 
