echo "AVERAGE"
for FILE in ./fct_results/*; do
    if ! [ -d "$FILE" ]; then
        FILENAME="${FILE##*/}"
        cat $FILE | awk -v filename=$FILENAME '{sum += $3}END{avg = sum/NR}END{print filename " " avg}'
    fi
done

echo -e "\nMEDIAN"
for FILE in ./fct_results/*; do
    if ! [ -d "$FILE" ]; then
        FILENAME="${FILE##*/}"
        sort -k3 -n $FILE | awk -v filename=$FILENAME '{nums[NR] = $3} END {median = (NR%2==0) ? (nums[NR/2]+nums[(NR/2)+1]) / 2 : nums[int(NR/2) + 1]} END {print filename " " median}'
    fi
done

echo -e "\n99TH PERCENTILE"
for FILE in ./fct_results/*; do
    if ! [ -d "$FILE" ]; then
        FILENAME="${FILE##*/}"
        sort -k3 -n $FILE  | awk -v filename=$FILENAME '{nums[NR] = $3} END {n99 = nums[int(NR*0.99)]} END {print filename " " n99}'
    fi
done

# echo -e "\nTEST"
# FILE="./fct_results/test.txt"
# FILENAME="${FILE##*/}"
# sort -k3 -n $FILE | awk -v filename=$FILENAME '{nums[NR] = $3} END {median = (NR%2==0) ? (nums[NR/2]+nums[(NR/2)+1]) / 2 : nums[int(NR/2) + 1]} END {print filename " " median}'
# sort -k3 -n $FILE  | awk -v filename=$FILENAME '{nums[NR] = $3} END {n99 = nums[int(NR*0.99)]} END {print filename " " n99}'