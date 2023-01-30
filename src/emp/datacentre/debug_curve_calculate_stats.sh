topology=rrg
routing=racke0
traffic=flat-16to4-0
mode=equal
values='1.95 3.9 5.85 7.8 9.75 11.7 13.65 15.6 17.55 19.5 21.45 23.4'
dir=debug_curve_jan29_flat-16to4-0

stime=1000
mstart=250
mend=750

seed=0
tempoutputfileprefix=${dir}/${topology}_${routing}_${traffic}_${mode}
tempoutputfilefraction=${tempoutputfileprefix}_fraction
tempoutputfilefcttraffic=${tempoutputfileprefix}_fcttraffic
tempoutputfilenetworkutil=${tempoutputfileprefix}_networkutil
tempoutputfilemaxlinkutil=${tempoutputfileprefix}_maxlinkutil

n99fctarr=()
trafficarr=()
lowernetworkutilarr=()
uppernetworkutilarr=()
lowermaxlinkutilarr=()
uppermaxlinkutilarr=()

# 1.Parse 2.Calculate n99fct and traffic
for value in $values
do
  ./discover_aux_fraction.sh $value > ${tempoutputfilefraction}
  mult=$(cat ${tempoutputfilefraction} | cut -d " " -f 1)
  numerator=$(cat ${tempoutputfilefraction} | cut -d " " -f 2)
  denominator=$(cat ${tempoutputfilefraction} | cut -d " " -f 3)

  inputfile=${dir}/${topology}_${routing}_${mode}_${mult}_${numerator}_${denominator}_${stime}_${seed}

  echo parse $value
  fctinputfile=${inputfile}_fct
  parsedinputfile=${inputfile}_parsed
  if [ ! -s $fctinputfile ]
  then
    cat $inputfile | grep -e "FCT" > $fctinputfile
  fi
  if [ ! -s $parsedinputfile ]
  then
    python pre_aux_parse_ls_report_generically.py $inputfile
  fi

  echo n99fct and traffic for $value
  ./discover_aux_single_stats.sh $fctinputfile $mstart $mend > $tempoutputfilefcttraffic
  linecount=0
  while IFS= read -r line
  do
    if [ $linecount -eq 0 ]
    then
      n99fct=$(echo $line | cut -d " " -f 7)
      n99fctarr+=( $n99fct )
    elif [ $linecount -eq 1 ]
    then
      totaltraffic=$(echo $line | cut -d " " -f 6)
      trafficarr+=( $totaltraffic )
    else
      echo $tempoutputfilefcttraffic has more than two lines.
    fi
    ((linecount++))
  done < $tempoutputfilefcttraffic
done

rm $tempoutputfilefcttraffic

# Calculate overall network util
for value in $values
do
  echo network util for $value
  ./discover_aux_fraction.sh $value > ${tempoutputfilefraction}
  mult=$(cat ${tempoutputfilefraction} | cut -d " " -f 1)
  numerator=$(cat ${tempoutputfilefraction} | cut -d " " -f 2)
  denominator=$(cat ${tempoutputfilefraction} | cut -d " " -f 3)

  parsedinputfile=${dir}/${topology}_${routing}_${mode}_${mult}_${numerator}_${denominator}_${stime}_${seed}_parsed
  python sanity_aux_calculate_network_util.py $parsedinputfile $mstart $mend > $tempoutputfilenetworkutil
  utillower=$(cat $tempoutputfilenetworkutil | cut -d " " -f 1)
  utilupper=$(cat $tempoutputfilenetworkutil | cut -d " " -f 2)
  lowernetworkutilarr+=( $utillower )
  uppernetworkutilarr+=( $utilupper )
done

rm $tempoutputfilenetworkutil

# Calculate max link util
for value in $values
do
  echo max link for $value
  ./discover_aux_fraction.sh $value > ${tempoutputfilefraction}
  mult=$(cat ${tempoutputfilefraction} | cut -d " " -f 1)
  numerator=$(cat ${tempoutputfilefraction} | cut -d " " -f 2)
  denominator=$(cat ${tempoutputfilefraction} | cut -d " " -f 3)

  parsedinputfile=${dir}/${topology}_${routing}_${mode}_${mult}_${numerator}_${denominator}_${stime}_${seed}_parsed
  python pre_aux_calculate_link_util_stats.py $parsedinputfile $mstart $mend > $tempoutputfilemaxlinkutil
  utillower=$(cat $tempoutputfilemaxlinkutil | cut -d " " -f 1)
  utilupper=$(cat $tempoutputfilemaxlinkutil | cut -d " " -f 2)
  lowermaxlinkutilarr+=( $utillower )
  uppermaxlinkutilarr+=( $utilupper )
done

rm $tempoutputfilemaxlinkutil
rm $tempoutputfilefraction

# Echo results
echo Finished.
echo "${trafficarr[*]}"
echo "${n99fctarr[*]}"
echo "${lowernetworkutilarr[*]}"
echo "${uppernetworkutilarr[*]}"
echo "${lowermaxlinkutilarr[*]}"
echo "${uppermaxlinkutilarr[*]}"
