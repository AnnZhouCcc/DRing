#!/bin/bash
# Set parameters.
topology=rrg
routing=su2
trafficmatrix=a2a
mode=equal #equal/lppbr/lpdbr
searchstart=0.4
searchend=0.6
threshold=5 #ms
stime=200
mstart=50
mend=150
precision=64

npfile=netpathfiles/netpath_${routing}_${topology}.txt

if [ $mode = "equal" ]
then
  pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_equal_${precision}.txt
elif [ $mode = "lppbr" ]
then
  pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_${trafficmatrix}_lp1_${precision}.txt
elif [ $mode = "lpdbr" ]
then
  pwfile=pathweightfiles/${topology}/${routing}/pathweight_pbr1_${topology}_${routing}_${trafficmatrix}_lp1_${precision}.txt
else
  echo mode $mode not recognized.
fi

if [ $topology = "rrg" ]
then
  graphfile=graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist
  numservers=3072
elif [ $topology = "dring"]
then
  graphfile=graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist
  numservers=2988
else
  echo topology $topology not recognized.
fi

if [ $trafficmatrix = "a2a" ]
then
  trafficmatrixparam=A2A
else
  echo traffic matrix $trafficmatrix not recognized.
fi

if [ $routing = "ecmp" ]
then
  routingparam=ecmp
  kornparam=0
elif [ $routing = "su2" ]
then
  routingparam=su
  kornparam=2
else
  echo routing $routing not recognized.
fi

# Set up a logfile.
dir=discover_${topology}_${routing}_${trafficmatrix}_${mode}
if [ ! -d $dir ]
then
  mkdir $dir
fi

logfile=${dir}/log.txt
if [ ! -e $logfile ]
then
  touch $logfile
fi

echo $(date): Set up parameters >> $logfile
echo topology=$topology >> $logfile
echo routing=$routing >> $logfile
echo trafficmatrix=$trafficmatrix >> $logfile
echo mode=$mode >> $logfile
echo searchstart=$searchstart >> $logfile
echo searchend=$searchend >> $logfile
echo threshold=$threshold >> $logfile
echo stime=$stime >> $logfile
echo mstart=$mstart >> $logfile
echo mend=$mend >> $logfile
echo precision=$precision >> $logfile

# Check initial interval.
tempoutputfile=${dir}/output
seed=0
suffix=${topology}_${routing}_${trafficmatrix}_${mode}
make=MAKE

./discover_aux_fraction.sh $searchstart > $tempoutputfile
multstart=$(cat $tempoutputfile | cut -d " " -f 1)
numeratorstart=$(cat $tempoutputfile | cut -d " " -f 2)
denominatorstart=$(cat $tempoutputfile | cut -d " " -f 3)

./discover_aux_fraction.sh $searchend > $tempoutputfile
multend=$(cat $tempoutputfile | cut -d " " -f 1)
numeratorend=$(cat $tempoutputfile | cut -d " " -f 2)
denominatorend=$(cat $tempoutputfile | cut -d " " -f 3)

### Search start.
echo $(date): Run experiment search start >> $logfile
echo mult=${multstart},numerator=${numeratorstart},denominator=${denominatorstart} >> $logfile

outputfilestart=${dir}/${multstart}_${numeratorstart}_${denominatorstart}_${stime}_${seed}
if [ ! -s $outputfilestart ]
then
  time ./run.sh RRG 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $multstart $numeratorstart $denominatorstart 0 0 $routingparam $kornparam 0 0 $seed $suffix $npfile $pwfile 0 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" > $outputfilestart &
  sleep 5 
  wait
  echo $(date): Experiment done >> $logfile
  make=NOMAKE
else
  echo $(date): Result already exists >> $logfile
fi

./discover_aux_collect_n99fct_totaltraffic_from_single_stats.sh $outputfilestart $mstart $mend $tempoutputfile > $tempoutputfile
n99fctstart=$(cat $tempoutputfile | cut -d " " -f 1)
totaltrafficstart=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fctstart},totaltraffic=${totaltrafficstart} >> $logfile

### Search end.
echo $(date): Run experiment search end >> $logfile
echo mult=${multend},numerator=${numeratorend},denominator=${denominatorend} >> $logfile

outputfileend=${dir}/${multend}_${numeratorend}_${denominatorend}_${stime}_${seed}
if [ ! -s $outputfileend ]
then
  time ./run.sh RRG 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $multend $numeratorend $denominatorend 0 0 $routingparam $kornparam 0 0 $seed $suffix $npfile $pwfile 0 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" > $outputfileend &
  sleep 5
  wait
  echo $(date): Experiment done >> $logfile
  make=NOMAKE
else
  echo $(date): Result already exists >> $logfile
fi

./discover_aux_collect_n99fct_totaltraffic_from_single_stats.sh $outputfileend $mstart $mend $tempoutputfile > $tempoutputfile
n99fctend=$(cat $tempoutputfile | cut -d " " -f 1)
totaltrafficend=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fctend},totaltraffic=${totaltrafficend} >> $logfile

### Compare n99fct.
isLessThan() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1<n2?"1":"0") "\n"}'
}

isGreaterThan() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1>n2?"1":"0") "\n"}'
}

if [ $( isGreaterThan $threshold $n99fctend ) -eq 1 ] || [ $( isLessThan $threshold $n99fctstart ) -eq 1 ]
then
  echo Initial search interval is not appropriate. Check logfile.
  echo $threshold '>' $n99fctend ? $( isGreaterThan $threshold $n99fctend ) >> $logfile
  echo $threshold '<' $n99fctstart ? $( isLessThan $threshold $n99fctstart ) >> $logfile
  exit 1
fi

# Binary search.
takeMidPoint() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {printf ((n1+n2)/2)}'
}

isCloseEnough() {
  awk -v start="$1" -v end="$2" 'BEGIN {printf ((end-start)/end < 0.02 ? "1" : "0")}'
}

shouldInOrder() {
  awk -v n1="$1" -v n2="$2" -v n3="$3" 'BEGIN {printf (((n1<n2) && (n2<n3)) ? "1" : "0")}'
}

echo $(date): Start binary search. >> $logfile
while true
do
  ### Run experiment.
  searchmid=$( takeMidPoint $searchstart $searchend )
  echo searchmid=${searchmid},searchstart=${searchstart},searchend=${searchend} >> $logfile

  ./discover_aux_fraction.sh $searchmid > $tempoutputfile
  mult=$(cat $tempoutputfile | cut -d " " -f 1)
  numerator=$(cat $tempoutputfile | cut -d " " -f 2)
  denominator=$(cat $tempoutputfile | cut -d " " -f 3)
  
  echo $(date): Run experiment >> $logfile
  echo mult=${mult},numerator=${numerator},denominator=${denominator} >> $logfile

  outputfile=${dir}/${mult}_${numerator}_${denominator}_${stime}_${seed}
  if [ ! -s $outputfile ]
  then
    time ./run.sh RRG 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $mult $numerator $denominator 0 0 $routingparam $kornparam 0 0 $seed $suffix $npfile $pwfile 0 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" > $outputfile &
    sleep 5
    wait
    echo $(date): Experiment done >> $logfile
    make=NOMAKE
  else
    echo $(date): Result already exists >> $logfile
  fi

  ### Collect stats.
  ./discover_aux_collect_n99fct_totaltraffic_from_single_stats.sh $outputfile $mstart $mend $tempoutpufile > $tempoutputfile
  n99fct=$(cat $tempoutputfile | cut -d " " -f 1)
  totaltraffic=$(cat $tempoutputfile | cut -d " " -f 2)
  echo $(date): n99fct=${n99fct},totaltraffic=${totaltraffic} >> $logfile

  ### End or continue with binary search.
  if [ $( isCloseEnough $totaltrafficstart $totaltrafficend ) -eq 1 ]
  then
    ##### Do not split the interval further.
    echo $(date): isCloseEnough searchstart=${searchstart},searchmid=${searchmid},searchend=${searchend} >> $logfile
    echo searchstart: n99fct=${n99fctstart},totaltraffic=${totaltrafficstart} >> $logfile
    echo searchmid: n99fct=${n99fct},totaltraffic=${totaltraffic} >> $logfile
    echo searchend: n99fct=${n99fctend},totaltraffic=${totaltrafficend} >> $logfile

    if [ $( isGreaterThan $n99fct $threshold ) -eq 1 ]
    then
      echo ========='['searchstart,searchmid']'========= >> $logfile
      echo ========='['${searchstart},${searchmid}']'========= >> $logfile
    elif [ $(isLessThan $n99fct $threshold ) -eq 1 ]
    then
      echo ========='['searchmid,searchend']'========= >> $logfile
      echo ========='['${searchmid},${searchend}']'========= >> $logfile
    else
      echo searchmid n99fct == threshold. >> $logfile
    fi

    break
  fi

  if [ $( isGreaterThan $n99fct $threshold ) -eq 1 ]
  then
    searchend=$searchmid
    n99fctend=$n99fct
    totaltrafficend=$totaltraffic
    echo Change searchend to $searchmid >> $logfile
    echo searchstart=${searchstart},searchend=${searchend} >> $logfile
    
    if [ $( shouldInOrder $n99fctstart $threshold $n99fct ) -eq 0 ]
    then
      echo fct not in order: n99fctstart=${n99fctstart},threshold=${threshold},n99fct=${n99fct} >> $logfile
      exit 1
    fi

  elif [ $(isLessThan $n99fct $threshold ) -eq 1 ]
  then
    searchstart=$searchmid
    n99fctstart=$n99fct
    totaltrafficstart=$totaltraffic
    echo Change searchstart to $searchmid >> $logfile
    echo searchstart=${searchstart},searchend=${searchend} >> $logfile

    if [ $( shouldInOrder $n99fct $threshold $n99fctend ) -eq 0 ]
    then
      echo fct not in order: n99fct=${n99fct},threshold=${threshold},n99fctend=${n99fctend} >> $logfile
      exit 1
    fi

  else
    echo n99fct is exactly equal to threshold.
    echo $(date): n99fct == threshold >> $logfile
    echo n99fct=${n99fct},threshold=${threshold} >> $logfile
    exit 1
  fi
done

echo Passed.
echo ===============Close Interval Found============== >> $logfile

# Repeated experiments.
#set different seed

rm $tempoutputfile
