# declare -a new_files=("dring_ecmp_a2a_16" "rrg_ecmp_a2a_16" "ls_a2a_16"
#                     "dring_s2_a2a_16" "rrg_s2_a2a_16"
#                     "dring_s2_cs_skewed_768_192_ann" "rrg_s2_cs_skewed_768_192_ann")
# prefix="fct_results/"
dir="./fct_results_628/*"
run_fct(){
    echo -e "\nAVERAGE"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME '{sum += $3}END{avg = sum/NR}END{print filename " " avg}'
        fi
    done

    echo -e "\nMEDIAN"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            sort -k3 -n $FILE | awk -v filename=$FILENAME '{nums[NR] = $3} END {median = (NR%2==0) ? (nums[NR/2]+nums[(NR/2)+1]) / 2 : nums[int(NR/2) + 1]} END {print filename " " median}'
        fi
    done

    echo -e "\n99TH PERCENTILE"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            sort -k3 -n $FILE  | awk -v filename=$FILENAME '{nums[NR] = $3} END {n99 = nums[int(NR*0.99)]} END {print filename " " n99}'
        fi
    done
}


run_flow_size(){
    echo -e "\nTOTAL FLOW SIZE | #FLOWS | AVERAGE FLOW SIZE"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME '{sum += $2}END{avg = sum/NR}END{print filename " " sum " " NR " " avg}'
        fi
    done
}


run_test(){
    echo -e "\nTEST"
    FILE="./fct_results/test.txt"
    FILENAME="${FILE##*/}"
    sort -k3 -n $FILE | awk -v filename=$FILENAME '{nums[NR] = $3} END {median = (NR%2==0) ? (nums[NR/2]+nums[(NR/2)+1]) / 2 : nums[int(NR/2) + 1]} END {print filename " " median}'
    sort -k3 -n $FILE  | awk -v filename=$FILENAME '{nums[NR] = $3} END {n99 = nums[int(NR*0.99)]} END {print filename " " n99}'
}


run_fct
run_flow_size
# run_test
