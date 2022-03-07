# declare -a new_files=("ls_fb_skewed_802v3_ii2_2_10" "ls_fb_skewed_802v3_ii2_3_10")
# prefix="./fct_results_802v3/"
dir="./fct_results_0227m6/*"
# mstart=0
mend=350

for mstart in 0; do
    echo -e "\nAVERAGE FCT | MEDIAN FCT/SIZE | N99 FCT/SIZE | MAX FCT/SIZE"
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
