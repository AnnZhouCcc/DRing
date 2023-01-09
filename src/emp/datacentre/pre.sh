#!/bin/bash
# Set parameters.
trafficmatrix=r2r0
trafficmatrixparam=S2S_1_1_0_0
stime=$1
load=$2
seedfrom=0
seedto=49

let mstart=$stime/4
let mend=3*$stime/4
numservers=3072
npfile=netpathfiles/netpath_ecmp_leafspine.txt
pwfile=pathweightfiles/leafspine/ecmp/pathweight_leafspine_ecmp_equal_64.txt

# Set up the logfile.
dir=discover_leafspine_ecmp_${trafficmatrix}_equal
if [ ! -d $dir ]
then
  mkdir $dir
fi

logfile=${dir}/log.txt
if [ ! -e $logfile ]
then
  touch $logfile
fi

echo ====================$(date)=================== >> $logfile
echo trafficmatrix=${trafficmatrix},${trafficmatrixparam} >> $logfile
echo stime=${stime},mstart=${mstart},mend=${mend} >> $logfile
echo numservers=$numservers >> $logfile

# Set up parameters for experiments.
suffix=leafspine_ecmp_${trafficmatrix}_equal
tempoutputfile=${dir}/${suffix}_output
make=MAKE

# Run experiment.
./discover_aux_fraction.sh $load > $tempoutputfile
mult=$(cat $tempoutputfile | cut -d " " -f 1)
numerator=$(cat $tempoutputfile | cut -d " " -f 2)
denominator=$(cat $tempoutputfile | cut -d " " -f 3)

outputfileprefix=${dir}/${mult}_${numerator}_${denominator}_${stime}

echo $(date): Run experiment >> $logfile
echo load=${load},mult=${mult},numerator=${numerator},denominator=${denominator} >> $logfile

for seed in $(seq $seedfrom $seedto)
do
  outputfile=${outputfileprefix}_${seed}
  if [ ! -s $outputfile ]
  then
    time ./run.sh LEAFSPINE 1 64 16 null $numservers 1 1 $make $trafficmatrixparam $mult $numerator $denominator 0 0 ecmp 0 0 0 $seed $suffix $npfile $pwfile 0 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" -e "^queue" > $outputfile &
    sleep 30
    wait
    make=NOMAKE
    echo $(date): Experiment done >> $logfile
  else
    echo $(date): Result already exists >> $logfile
  fi
done

# Process the output files.
combinedfctoutputfile=${dir}/${mult}_${numerator}_${denominator}_${stime}_${seedfrom}_${seedto}
for seed in $(seq $seedfrom $seedto)
do
  outputfile=${dir}/${mult}_${numerator}_${denominator}_${stime}_${seed}
  fctoutputfile=${outputfile}_fct 
  cat $outputfile | grep -e "FCT" > $fctoutputfile
  parsedoutputfile=${outputfile}_parsed
  if [ ! -s $parsedoutputfile ]
  then
    python pre_aux_parse_ls_report_generically.py $outputfile
  fi
  cat $fctoutputfile >> $combinedfctoutputfile
done

# Calculate fct and flow size stats.
./discover_aux_single_stats.sh $combinedfctoutputfile $mstart $mend > $tempoutputfile
linecount=0
while IFS= read -r line
do
  if [ $linecount -eq 0 ]
  then
    # fct stats
    n99fct=$(echo $line | cut -d " " -f 7)
  elif [ $linecount -eq 1 ]
  then
    # flow size stats
    totaltraffic=$(echo $line | cut -d " " -f 6)
  fi
  ((linecount++))
done < $tempoutputfile
echo n99fct=${n99fct},totaltraffic=${totaltraffic} >> $logfile

# Calculate network utilization.
./pre_aux_calculate_average_max_link_util.sh $outputfileprefix $seedfrom $seedto $mstart $mend > $tempoutputfile
utillower=$(cat $tempoutputfile | cut -d " " -f 1)
utilupper=$(cat $tempoutputfile | cut -d " " -f 2)
echo utillower=${utillower},utilupper=${utilupper} >> $logfile

# Ask for user inputs for time and memory usage.
#read -p 'Time: ' timevar
#read -p 'Initial memory: ' initialmem
#read -p 'Peak memory: ' peakmem
#memvar=$(echo $peakmem - $initialmem | bc)
#echo time=$timevar >> $logfile
#echo initialmem=${initialmem},peakmem=${peakmem},mem=${memvar} >> $logfile

# Write out to terminal.
echo n99fct=${n99fct},totaltraffic=${totaltraffic}
echo utillower=${utillower},utilupper=${utilupper}
#echo time=${timevar},mem=${memvar}

# Remove some output files.
rm $tempoutputfile
rm $combinedfctoutputfile
for seed in $(seq $seedfrom $seedto)
do
  fctoutputfile=${outputfileprefix}_${seed}_fct
  #parsedoutputfile=${outputfileprefix}_${seed}_parsed
  rm $fctoutputfile
  #rm $parsedoutputfile
done
