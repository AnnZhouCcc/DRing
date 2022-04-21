# declare -a new_files=("ls_fb_skewed_802v3_ii2_2_10" "ls_fb_skewed_802v3_ii2_3_10")
# prefix="./fct_results_802v3/"
dir="./fct_results_0421t2000cssls/*"
mstart=100
mend=200

for mstart in $mstart; do
    echo -e "\nCAPACITY | LSUM | USUM | LUTIL | UUTIL"
    for FILE in ${dir}; do
    # for FILE in "${new_files[@]}"; do
    #     FILE="${prefix}${FILE}"
        if ! [ -d "$FILE" ]; then
            FILENAME="${FILE##*/}"
            cat $FILE | awk -v filename=$FILENAME -v mstart=$mstart -v mend=$mend -f stats_util.awk
        fi
    done
done
