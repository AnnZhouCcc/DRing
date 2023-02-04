#!/bin/bash
# Set parameters.
topology=$1 #rrg/dring/leafspine
routing=$2
trafficmatrix=clustera
mode=$3 #equal/weighted/lppbr/lpdbr/lppbr-optimal/lpdbr-optimal/lppbr-nox-optimal/lpdbr-nox-optimal/lppbr-nox-delay/lpdbr-nox-delay/lppbr-delay/lpdbr-delay/lppbr-nox/lpdbr-nox
lpsolvermode=$4
searchstart=$5
searchend=$6
threshold=10 #ms
stime=200
precision=64
seedfrom=0
seedto=0
solvestart=0
solveend=79200
trafficfilename=a
dp=$precision
solveinterval=7200
computestart=0
computeend=79200
computeinterval=$7

# Check for input parameter error
if [ ! $threshold -eq 10 ]
then
  echo threshold!=10, threshold=$threshold
  exit 1
fi

if [ ! $lpsolvermode = "barriernocrossover" ] && [ ! $lpsolvermode = "null" ]
then
  echo lpsolvermode $lpsolvermode is not recognized
  exit 1
fi

if [ ! $trafficmatrix = "clustera" ] && [ ! $trafficmatrix = "clusterb" ] && [ ! $trafficmatrix = "clusterc" ] && [ ! $computeinterval -eq 0 ]
then
  echo traffic $trafficmatrix has computeinterval!=0, computeinterval=$computeinterval
  exit 1
fi

if [ ! $( echo $solveend - $solvestart - $computeend + $computestart | bc ) -eq 0 ]
then
  echo solveend-solvestart!=computeend-computestart, solveend=${solveend}, solvestart=${solvestart}, computeend=${computeend}, computestart=${computestart}
  exit 1
fi

if [ $mode = "lppbr-optimal" ] || [ $mode = "lpdbr-optimal" ] || [ $mode = "lppbr-nox-optimal" ] || [ $mode = "lpdbr-nox-optimal" ] || [ $mode = "lpdbr-optimal-900" ] || [ $mode = "lpdbr-optimal-1800" ] || [ $mode = "lpdbr-optimal-3600" ] || [ $mode = "lpdbr-optimal-7200" ]
then
  if [ ! $( echo $solvestart - $computestart | bc ) -eq 0 ] || [ ! $( echo $solveend - $computeend | bc ) -eq 0 ]
  then
    echo solvestart!=computestart or solveend!=computeend, solveend=${solveend}, solvestart=${solvestart}, computeend=${computeend}, computestart=${computestart}
    exit 1
  fi
fi

if [ $mode = "lppbr-delay" ] || [ $mode = "lpdbr-delay" ] || [ $mode = "lppbr-nox-delay" ] || [ $mode = "lpdbr-nox-delay" ] || [ $mode = "lpdbr-delay-900" ] || [ $mode = "lpdbr-delay-1800" ] || [ $mode = "lpdbr-delay-3600" ] || [ $mode = "lpdbr-delay-7200" ]
then
  if [ ! $computestart -lt $solvestart ] || [ ! $computeend -lt $solveend ]
  then 
    echo computestart gte solvestart or computeend gte solveend, solveend=${solveend}, solvestart=${solvestart}, computeend=${computeend}, computestart=${computestart}
    exit 1
  fi    
fi

if [ ! $trafficmatrix = "clustera" ] && [ ! $trafficmatrix = "clusterb" ] && [ ! $trafficmatrix = "clusterc" ]
then
  if [ $mode = "lppbr-optimal" ] || [ $mode = "lpdbr-optimal" ] || [ $mode = "lppbr-nox-optimal" ] || [ $mode = "lpdbr-nox-optimal" ] || [ $mode = "lppbr-delay" ] || [ $mode = "lpdbr-delay" ] || [ $mode = "lppbr-nox-delay" ] || [ $mode = "lpdbr-nox-delay" ]
  then
    echo traffic $trafficmatrix should not have mode $mode
    exit 1
  fi
else
  if [ $mode = "lppbr" ] || [ $mode = "lpdbr" ] || [ $mode = "lppbr-nox" ] || [ $mode = "lpdbr-nox" ]
  then
    echo traffic $trafficmatrix should not have mode $mode
    exit 1
  fi
fi

if [ ! $computeinterval -eq 0 ] && [ $mode = "equal" ]
then
  echo mode is equal but computeinterval!=0, computeinterval=$computeinterval
  exit 1
fi

# Generate other parameters
let mstart=$stime/4
let mend=3*$stime/4

npfile=netpathfiles/netpath_${routing}_${topology}.txt

if [ $computeinterval -eq 0 ]
then
  if [ $mode = "equal" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_equal_${precision}.txt
  elif [ $mode = "weighted" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_weighted_${precision}.txt
  elif [ $mode = "lppbr" ] || [ $mode = "lppbr-nox" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/${trafficmatrix}/pathweight_${topology}_${routing}_${trafficmatrix}_lp1_${lpsolvermode}_${precision}.txt
  elif [ $mode = "lpdbr" ] || [ $mode = "lpdbr-nox" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/${trafficmatrix}/pathweight_pbr1_${topology}_${routing}_${trafficmatrix}_lp1_${lpsolvermode}_${precision}.txt
  else
    echo mode $mode not recognized.
  fi
else
  if [ $mode = "equal" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_equal_${precision}.txt
  elif [ $mode = "lppbr-optimal" ] || [ $mode = "lppbr-nox-optimal" ] || [ $mode = "lppbr-nox-delay" ] || [ $mode = "lppbr-delay" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/${trafficmatrix}/pathweight_${topology}_${routing}_${trafficmatrix}_lp1_${lpsolvermode}_
  elif [ $mode = "lpdbr-optimal" ] || [ $mode = "lpdbr-nox-optimal" ] || [ $mode = "lpdbr-nox-delay" ] || [ $mode = "lpdbr-delay" ] || [ $mode = "lpdbr-optimal-900" ] || [ $mode = "lpdbr-optimal-1800" ] || [ $mode = "lpdbr-optimal-3600" ] || [ $mode = "lpdbr-optimal-7200" ] || [ $mode = "lpdbr-delay-900" ] || [ $mode = "lpdbr-delay-1800" ] || [ $mode = "lpdbr-delay-3600" ] || [ $mode = "lpdbr-delay-7200" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/${trafficmatrix}/pathweight_pbr1_${topology}_${routing}_${trafficmatrix}_lp1_${lpsolvermode}_
  else
    echo mode $mode not recognized.
  fi
fi

if [ $topology = "rrg" ]
then
  graphname=RRG
  graphfile=graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist
  numservers=3072
elif [ $topology = "dring" ]
then
  graphname=RRG
  graphfile=graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist
  numservers=2988
elif [ $topology = "leafspine" ]
then
  graphname=LEAFSPINE
  graphfile=null
  numservers=3072
else
  echo topology $topology not recognized.
fi

if [ $trafficmatrix = "a2a" ]
then
  trafficmatrixparam=A2A
elif [ $trafficmatrix = "r2r0" ]
then
  trafficmatrixparam=S2S_1_1_0_0
elif [ $trafficmatrix = "r2r1" ]
then
  trafficmatrixparam=S2S_1_1_0_1
elif [ $trafficmatrix = "16to4-0" ]
then
  trafficmatrixparam=S2S_16_4_0_0
elif [ $trafficmatrix = "16to4-1" ]
then
  trafficmatrixparam=S2S_16_4_0_1
elif [ $trafficmatrix = "16to4-2" ]
then
  trafficmatrixparam=S2S_16_4_0_2
elif [ $trafficmatrix = "flat-16to4-0" ]
then
  trafficmatrixparam=F2F_16_4_0_0
elif [ $trafficmatrix = "clusterb" ] || [ $trafficmatrix = "clustera" ] || [ $trafficmatrix = "clusterc" ]
then
  trafficmatrixparam=CLUSTERX
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
elif [ $routing = "su3" ]
then
  routingparam=su
  kornparam=3
elif [ $routing = "32disjoint" ]
then
  routingparam=kdisjoint
  kornparam=32
elif [ $routing = "32short" ]
then
  routingparam=kshort
  kornparam=32
elif [ $routing = "racke0" ]
then
  routingparam=racke
  kornparam=0
elif [ $routing = "racke1" ]
then
  routingparam=racke
  kornparam=1
elif [ $routing = "racke2" ]
then
  routingparam=racke
  kornparam=2
else
  echo routing $routing not recognized.
fi

# Set up a logfile.
dir=rediscover_${topology}_${routing}_${trafficmatrix}_${mode}
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
suffix=${topology}_${routing}_${trafficmatrix}_${mode}
tempoutputfile=${dir}/${suffix}_output
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

outputfileprefixstart=${dir}/${multstart}_${numeratorstart}_${denominatorstart}_${stime}

for seed in $(seq $seedfrom $seedto)
do
  outputfilestart=${outputfileprefixstart}_${seed}
  if [ ! -s $outputfilestart ]
  then
    time ./run.sh $graphname 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $multstart $numeratorstart $denominatorstart $solvestart $solveend $routingparam $kornparam $trafficfilename 0 $seed $suffix $npfile $pwfile $dp $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" > $outputfilestart &
    sleep 5 
    wait
    echo $(date): Experiment done "("seed=$seed")" >> $logfile
    make=NOMAKE
  else
    echo $(date): Result already exists "("seed=$seed")" >> $logfile
  fi
done

combinedoutputfilestart=${outputfileprefixstart}_${seedfrom}_${seedto}
if [ -e $combinedoutputfilestart ]
then
  rm $combinedoutputfilestart
fi
for seed in $(seq $seedfrom $seedto)
do
  outputfilestart=${outputfileprefixstart}_${seed}
  cat $outputfilestart >> $combinedoutputfilestart
done

./discover_aux_collect_n99fct_totaltraffic_from_single_stats.sh $combinedoutputfilestart $mstart $mend $tempoutputfile > $tempoutputfile
n99fctstart=$(cat $tempoutputfile | cut -d " " -f 1)
totaltrafficstart=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fctstart},totaltraffic=${totaltrafficstart} >> $logfile
rm $combinedoutputfilestart

### Search end.
echo $(date): Run experiment search end >> $logfile
echo mult=${multend},numerator=${numeratorend},denominator=${denominatorend} >> $logfile

outputfileprefixend=${dir}/${multend}_${numeratorend}_${denominatorend}_${stime}

for seed in $(seq $seedfrom $seedto)
do
  outputfileend=${outputfileprefixend}_${seed}
  if [ ! -s $outputfileend ]
  then
    time ./run.sh $graphname 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $multend $numeratorend $denominatorend $solvestart $solveend $routingparam $kornparam $trafficfilename 0 $seed $suffix $npfile $pwfile $dp $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" > $outputfileend &
    sleep 5
    wait
    echo $(date): Experiment done "("seed=$seed")" >> $logfile
    make=NOMAKE
  else
    echo $(date): Result already exists "("seed=$seed")" >> $logfile
  fi
done

combinedoutputfileend=${outputfileprefixend}_${seedfrom}_${seedto}
if [ -e $combinedoutputfileend ]
then
  rm $combinedoutputfileend
fi
for seed in $(seq $seedfrom $seedto)
do
  outputfileend=${outputfileprefixend}_${seed}
  cat $outputfileend >> $combinedoutputfileend
done

./discover_aux_collect_n99fct_totaltraffic_from_single_stats.sh $combinedoutputfileend $mstart $mend $tempoutputfile > $tempoutputfile
n99fctend=$(cat $tempoutputfile | cut -d " " -f 1)
totaltrafficend=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fctend},totaltraffic=${totaltrafficend} >> $logfile
rm $combinedoutputfileend

### Compare n99fct.
isLessThan() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1<n2?"1":"0") "\n"}'
}

isGreaterThan() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1>n2?"1":"0") "\n"}'
}

if [ $( isGreaterThan $threshold $n99fctend ) -eq 1 ] || [ $( isLessThan $threshold $n99fctstart ) -eq 1 ]
then
  echo $dir
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
  awk -v start="$1" -v end="$2" 'BEGIN {printf ((end-start)/end < 0.04 ? "1" : "0")}'
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

  outputfileprefix=${dir}/${mult}_${numerator}_${denominator}_${stime}

  for seed in $(seq $seedfrom $seedto)
  do
    outputfile=${outputfileprefix}_${seed}
    if [ ! -s $outputfile ]
    then
      time ./run.sh $graphname 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $mult $numerator $denominator $solvestart $solveend $routingparam $kornparam $trafficfilename 0 $seed $suffix $npfile $pwfile $dp $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" > $outputfile &
      sleep 5
      wait
      echo $(date): Experiment done "("seed=$seed")" >> $logfile
      make=NOMAKE
    else
      echo $(date): Result already exists "("seed=$seed")" >> $logfile
    fi
  done

  combinedoutputfile=${outputfileprefix}_${seedfrom}_${seedto}
  if [ -e $combinedoutputfile ]
  then
    rm $combinedoutputfile
  fi
  for seed in $(seq $seedfrom $seedto)
  do
    outputfile=${outputfileprefix}_${seed}
    cat $outputfile >> $combinedoutputfile
  done

  ### Collect stats.
  ./discover_aux_collect_n99fct_totaltraffic_from_single_stats.sh $combinedoutputfile $mstart $mend $tempoutputfile > $tempoutputfile
  n99fct=$(cat $tempoutputfile | cut -d " " -f 1)
  totaltraffic=$(cat $tempoutputfile | cut -d " " -f 2)
  echo $(date): n99fct=${n99fct},totaltraffic=${totaltraffic} >> $logfile
  rm $combinedoutputfile

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
      ./rigorous.sh $searchstart $searchmid $topology $routing $trafficmatrix $mode $threshold $stime $mstart $mend $precision $seedfrom $seedto 0 9 $npfile $pwfile $graphname $graphfile $numservers $trafficmatrixparam $routingparam $kornparam $solvestart $solveend $trafficfilename $dp $solveinterval $computestart $computeend $computeinterval> $tempoutputfile
      x=$(cat $tempoutputfile | cut -d " " -f 1)
      echo $x
    elif [ $(isLessThan $n99fct $threshold ) -eq 1 ]
    then
      echo ========='['searchmid,searchend']'========= >> $logfile
      echo ========='['${searchmid},${searchend}']'========= >> $logfile
      ./rigorous.sh $searchmid $searchend $topology $routing $trafficmatrix $mode $threshold $stime $mstart $mend $precision $seedfrom $seedto 0 9 $npfile $pwfile $graphname $graphfile $numservers $trafficmatrixparam $routingparam $kornparam $solvestart $solveend $trafficfilename $dp $solveinterval $computestart $computeend $computeinterval > $tempoutputfile
      x=$(cat $tempoutputfile | cut -d " " -f 1)
      echo $x
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

echo $dir
echo Passed.
echo ===============Close Interval Found============== >> $logfile

rm $tempoutputfile
if [ $topology = "leafspine" ]
then
  rm leafspine_${topology}_${routing}_${trafficmatrix}_${mode}
else
  rm rrg_${topology}_${routing}_${trafficmatrix}_${mode}
fi
