FILE="./fct_results_802v3/ls_fb_skewed_802v3_ii2_3_10"
re=".*(fb|a2a).*"
echo -e "\nEXTRACT_DATA"
FILENAME="${FILE##*/}"
if [[ $FILENAME =~ $re ]]; then
	tail -n +2 $FILE | awk  '{ print $3 }' > freq.txt
else
	tail -n +4 $FILE | awk '{ print $3}' > freq.txt
fi
