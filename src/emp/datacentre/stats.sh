# declare -a new_files=("ls_fb_skewed_802v3_ii2_2_10" "ls_fb_skewed_802v3_ii2_3_10")
# prefix="./fct_results_802v3/"
dir="./fct_results_916v3/*"
# re=".*(fb|a2a).*"
run_fct(){
    echo -e "\nAVERAGE"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -f stats_average.awk
        fi
    done

    echo -e "\nMEDIAN"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -f stats_median.awk
        fi
    done

    echo -e "\n99TH PERCENTILE"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
        FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -f stats_n99.awk
        fi
    done

    # echo -e "\n99p99TH PERCENTILE"
    # for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
    #     if ! [ -d "$FILE" ]; then
    #         FILENAME="${FILE##*/}"
    #         cat $FILE | awk -v filename=$FILENAME -f stats_n99p99.awk
    #     fi
    # done
}


run_flow_size(){
    echo -e "\nTOTAL FLOW SIZE | #FLOWS | AVERAGE FLOW SIZE | ACTUAL PACKET BYTES"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -f stats_flow_size.awk
        fi
    done
}


run_topology(){
    echo -e "\nTOTAL/AVG PATH LENGTH | TOTAL/AVG AVAILABLE PATHS | TOTAL/AVG AVAILABLE FIRST HOPS"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
	    cat $FILE | awk -v filename=$FILENAME -f stats_topology.awk
        fi
    done
}


run_aggregate_stats() {
    echo -e "\nTOTAL | AVERAGE PATH LENGTH"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME '{data[NR] = $3}END{print filename " " data[NR] " " data[NR]/(NR-1)}'
        fi
    done

    echo -e "\nTOTAL | AVERAGE BYTES SENT"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME '{data[NR] = $2}END{print filename " " data[NR] " " data[NR]/(NR-1)}'
        fi
    done
}


run_utilization() {
    echo -e "\nTOTAL BYTES SENT"
    for FILE in ${dir}; do
    if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME '{total_num_packets[NR] = $5}END{packet_size[NR] = $6}END{total_packet_bytes[NR] = $7}END{total_bytes = total_num_packets[NR] * packet_size[NR]}END{print filename " " total_bytes " " total_packet_bytes[NR]}'
        fi
    done 
}


run_comparison_flow_size_utilization() {
    echo -e "\nTOTAL FLOW SIZE | TOTAL BYTES SENT"
    for FILE in ${dir}; do
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME '{sum += $2}END{total_packet_bytes[NR] = $7}END{print filename " " sum " " total_packet_bytes[NR]}'
        fi
    done

}


run_test(){
    echo -e "\n99TH PERCENTILE"
    # for FILE in ${dir}; do
    for FILE in "${new_files[@]}"; do
        FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -f stats_fct.awk
        fi
    done
}


run_grep() {
    FILE="graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist_RRG_1_64_16_2988_1_MAKE_FEW_TO_SOME_768_dring_kshort_80_64_1_rrg_output__kshort_4"
    cat $FILE | grep "FCT" > fct_results_704/dring_kshort_4_cs_skewed_768_192_704_ii2_894784
}


run_fct
run_flow_size
run_topology
# run_aggregate_stats
# run_utilization
# run_comparison_flow_size_utilization
# run_test
# run_grep
