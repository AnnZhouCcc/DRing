dir=$1
filepre=$2

./rigorous_aux_multiple_stats.sh ${dir}/${filepre} 0 0 0 0 100 300 >> ${dir}/${filepre}_summary
