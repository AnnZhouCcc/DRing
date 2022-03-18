FILE="./fct_results_0311fct/fct_6"
mstart=0
mend=300
n95=50

cat $FILE | awk -v mstart=$mstart -v mend=$mend -v n95=$n95 -f stats_rank2.awk
