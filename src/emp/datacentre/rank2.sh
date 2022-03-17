FILE="./fct_results_0227m18/rrg_ecmp_0_4to16_0227long1_ii18_0_0_long1_0_1051_1050"
mstart=0
mend=350
n95=30.43174

cat $FILE | awk -v mstart=$mstart -v mend=$mend -v n95=$n95 -f stats_rank2.awk
