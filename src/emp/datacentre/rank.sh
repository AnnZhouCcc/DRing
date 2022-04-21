FILE="./fct_results_0322report/maxdisjoint27_report"
mstart=0
mend=1050
n95=19.5916

cat $FILE | awk -v mstart=$mstart -v mend=$mend -v n95=$n95 -f stats_rank.awk
