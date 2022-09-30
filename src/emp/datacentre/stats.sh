# declare -a new_files=("ls_fb_skewed_802v3_ii2_2_10" "ls_fb_skewed_802v3_ii2_3_10")
# prefix="./fct_results_802v3/"
#dir="./fct_results_archive/fct_results_0409t2000css32disjoint/*"
dir="./fct_results_lsclusterbecmp/*"
mstart=250
mend=1000
#duration=15

for mstart in $mstart; do
#for mstart in {5..65..15}; do
#for mend in {900..1900..200}; do
    #mend=`expr $mstart + $duration`
    echo -e "\nAVERAGE | MEDIAN | N95 | N99 | MAX | TAIL AVERAGE"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -v mstart=$mstart -v mend=$mend -f stats_fct.awk
        fi
    done

    echo -e "\nDURATION | #FLOWS | TOTAL FLOW SIZE | AVERAGE FLOW SIZE | #FLOW STARTS/TIME | TOTAL FLOW SIZE/TIME | FLOWxDURATION/TIME"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -v mstart=$mstart -v mend=$mend -f stats_flow_size.awk
        fi
    done
done
