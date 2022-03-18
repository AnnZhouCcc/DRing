FILE="./fct_results_0311report/report_6"
mstart=50
mend=300
n95=31.4371

cat $FILE | awk -v mstart=$mstart -v mend=$mend -v n95=$n95 -f stats_rank.awk
