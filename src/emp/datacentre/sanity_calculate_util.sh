outputfileprefix=$1
seedfrom=$2
seedto=$3
mstart=$4
mend=$5

tempoutputfile=${outputfileprefix}_util_output

utillowersum=0
utiluppersum=0
let numruns=$seedto-$seedfrom+1
for seed in $(seq $seedfrom $seedto)
do
  outputfile=${outputfileprefix}_${seed}
  fctoutputfile=${outputfile}_fct
  parsedoutputfile=${outputfileprefix}_${seed}_parsed
  if [ ! -s $fctoutputfile ]
  then
    cat $outputfile | grep -e "FCT" > $fctoutputfile
  fi
  if [ ! -s $parsedoutputfile ]
  then
    python pre_aux_parse_ls_report_generically.py $outputfile
  fi
  python sanity_aux_calculate_network_util.py $parsedoutputfile $mstart $mend > $tempoutputfile
  utillower=$(cat $tempoutputfile | cut -d " " -f 1)
  utilupper=$(cat $tempoutputfile | cut -d " " -f 2)
  utillowersum=$(echo $utillowersum + $utillower | bc)
  utiluppersum=$(echo $utiluppersum + $utilupper | bc)
done

divide() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1/n2)}'
}

utilloweraverage=$(divide $utillowersum $numruns)
utilupperaverage=$(divide $utiluppersum $numruns)

echo $utilloweraverage $utilupperaverage
rm $tempoutputfile
