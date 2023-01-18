#!/bin/bash
# Set parameters.
trafficmatrix=clusterb
trafficmatrixparam=CLUSTERX
stime=$1
load=$2
seedfrom=0
seedto=0
solvestart=0
solveend=84600
trafficfilename=b
dp=64
solveinterval=1800
computestart=0
computeend=84600
computeinterval=0

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
    time ./run.sh LEAFSPINE 1 64 16 null $numservers 1 1 $make $trafficmatrixparam $mult $numerator $denominator $solvestart $solveend ecmp 0 $trafficfilename 0 $seed $suffix $npfile $pwfile $dp $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" -e "^queue" > $outputfile &
    sleep 30
    wait
    make=NOMAKE
    echo $(date): Experiment done "("seed=$seed")" >> $logfile
  else
    echo $(date): Result already exists "("seed=$seed")" >> $logfile
  fi
done

# Process the output files.
combinedfctoutputfile=${outputfileprefix}_${seedfrom}_${seedto}
for seed in $(seq $seedfrom $seedto)
do
  outputfile=${outputfileprefix}_${seed}
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
./discover_aux_collect_n99fct_totaltraffic_from_single_stats.sh $combinedfctoutputfile $mstart $mendi $tempoutputfile > $tempoutputfile
n99fct=$(cat $tempoutputfile | cut -d " " -f 1)
totaltraffic=$(cat $tempoutputfile | cut -d " " -f 2)
echo n99fct=${n99fct},totaltraffic=${totaltraffic} >> $logfile

# Calculate network utilization.
./pre_aux_calculate_average_max_link_util.sh $outputfileprefix $seedfrom $seedto $mstart $mend > $tempoutputfile
utillower=$(cat $tempoutputfile | cut -d " " -f 1)
utilupper=$(cat $tempoutputfile | cut -d " " -f 2)
echo utillower=${utillower},utilupper=${utilupper} >> $logfile

# Ask for user inputs for time and memory usage.
read -p 'Time: ' timevar
read -p 'Initial memory: ' initialmem
read -p 'Peak memory: ' peakmem
memvar=$(echo $peakmem - $initialmem | bc)
echo time=$timevar >> $logfile
echo initialmem=${initialmem},peakmem=${peakmem},mem=${memvar} >> $logfile

# Write out to terminal.
echo n99fct=${n99fct},totaltraffic=${totaltraffic}
echo utillower=${utillower},utilupper=${utilupper}
echo time=${timevar},mem=${memvar}

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
