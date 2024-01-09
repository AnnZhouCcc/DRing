#!/bin/bash
# Set parameters.
p1=$1
p2=$2
topology=$3
routing=$4
trafficmatrix=$5
mode=$6
threshold=$7
stime=$8
mstart=$9
mend=${10}
precision=${11}
discoverseedfrom=${12}
discoverseedto=${13}
rigorousseedfrom=${14}
rigorousseedto=${15}
npfile=${16}
pwfile=${17}
graphname=${18}
graphfile=${19}
numservers=${20}
trafficmatrixparam=${21}
routingparam=${22}
kornparam=${23}
solvestart=${24}
solveend=${25}
trafficfilename=${26}
dp=${27}
solveinterval=${28}
computestart=${29}
computeend=${30}
computeinterval=${31}
decaymode=${32}
n=${33}
nors=${34}
seednumpw=${35}
seednumtraffic=${36}
pwnum=${37}

# Check the directory and logfile are present.
dir=oblivious_c2s_discover_${topology}_${routing}_${trafficmatrix}_${mode}_${n}_${nors}_${seednumpw}_${seednumtraffic}_$pwnum
if [ ! -d $dir ]
then
  echo Directory $dir not found.
fi

logfile=${dir}/log.txt
if [ ! -e $logfile ]
then
  echo Logfile $logfile not found.
fi

# Set up the logfile.
echo ================================================= >> $logfile
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ >> $logfile
echo $(date) >> $logfile
echo topology=$topology >> $logfile
echo routing=$routing >> $logfile
echo trafficmatrix=$trafficmatrix >> $logfile
echo mode=$mode >> $logfile
echo p1=$p1 >> $logfile
echo p2=$p2 >> $logfile
echo threshold=$threshold >> $logfile
echo stime=$stime >> $logfile
echo mstart=$mstart >> $logfile
echo mend=$mend >> $logfile
echo precision=$precision >> $logfile

# Set up for experiments.
suffix=${topology}_${routing}_${trafficmatrix}_${mode}_${n}_${nors}_${seednumpw}_${seednumtraffic}_$pwnum
tempoutputfile=${dir}/${suffix}_rigorous_output
make=MAKE

# Run experiments for p1.
./discover_aux_fraction.sh $p1 > $tempoutputfile
mult1=$(cat $tempoutputfile | cut -d " " -f 1)
numerator1=$(cat $tempoutputfile | cut -d " " -f 2)
denominator1=$(cat $tempoutputfile | cut -d " " -f 3)

echo $(date): Run experiment for p1 >> $logfile
echo mult=${mult1},numerator=${numerator1},denominator=${denominator1} >> $logfile

outputfileprefix1=${dir}/${mult1}_${numerator1}_${denominator1}_${stime}

calculateSeedFrom() {
  awk -v rigorousseed="$1" -v discoverseedfrom="$2" -v discoverseedto="$3" 'BEGIN {printf (rigorousseed*(discoverseedto-discoverseedfrom+1))}'
}

calculateSeedTo() {
  awk -v rigorousseed="$1" -v discoverseedfrom="$2" -v discoverseedto="$3" 'BEGIN {printf ((rigorousseed+1)*(discoverseedto-discoverseedfrom+1)-1)}'
}

for rigorousseed in $(seq $rigorousseedfrom $rigorousseedto)
do
  seedfrom=$(calculateSeedFrom $rigorousseed $discoverseedfrom $discoverseedto)
  seedto=$(calculateSeedTo $rigorousseed $discoverseedfrom $discoverseedto)
  echo $(date): rigorousseed=${rigorousseed},seedfrom=${seedfrom},seedto=${seedto} >> $logfile

  for seed in $(seq $seedfrom $seedto)
  do
    outputfile1=${outputfileprefix1}_${seed}
    echo $(date): Running seed=${seed} >> $logfile
    if [ ! -s $outputfile1 ]
    then
      time ./run.sh $graphname 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $mult1 $numerator1 $denominator1 $solvestart $solveend $routingparam $kornparam $trafficfilename 0 $seed $suffix $npfile $pwfile $dp $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" > $outputfile1 &
      sleep 30
      wait
      echo $(date): Experiment done "("seed=$seed")" >> $logfile
      make=NOMAKE
    else
      echo $(date): Result already exists "("seed=$seed")" >> $logfile
    fi
  done

  combinedoutputfile1=${outputfileprefix1}_${seedfrom}_${seedto}
  if [ -e $combinedoutputfile1 ]
  then
    rm $combinedoutputfile1
  fi
  for seed in $(seq $seedfrom $seedto)
  do
    outputfile1=${outputfileprefix1}_${seed}
    cat $outputfile1 >> $combinedoutputfile1
  done
done

echo $(date): Collecting stats for $outputfileprefix1 >> $logfile
./rigorous_aux_collect_n99fct_totaltraffic_from_multiple_stats.sh $outputfileprefix1 $rigorousseedfrom $rigorousseedto $discoverseedfrom $discoverseedto $mstart $mend ${outputfileprefix1}_summary > $tempoutputfile
n99fct1=$(cat $tempoutputfile | cut -d " " -f 1)
totaltraffic1=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fct1},totaltraffic=${totaltraffic1} >> $logfile

for rigorousseed in $(seq $rigorousseedfrom $rigorousseedto)
do
  seedfrom=$(calculateSeedFrom $rigorousseed $discoverseedfrom $discoverseedto)
  seedto=$(calculateSeedTo $rigorousseed $discoverseedfrom $discoverseedto)
  combinedoutputfile1=${outputfileprefix1}_${seedfrom}_${seedto}
  rm $combinedoutputfile1
done

# Run experiments for p2.
./discover_aux_fraction.sh $p2 > $tempoutputfile
mult2=$(cat $tempoutputfile | cut -d " " -f 1)
numerator2=$(cat $tempoutputfile | cut -d " " -f 2)
denominator2=$(cat $tempoutputfile | cut -d " " -f 3)

echo $(date): Run experiment for p2 >> $logfile
echo mult=${mult2},numerator=${numerator2},denominator=${denominator2} >> $logfile

outputfileprefix2=${dir}/${mult2}_${numerator2}_${denominator2}_${stime}

for rigorousseed in $(seq $rigorousseedfrom $rigorousseedto)
do
  seedfrom=$(calculateSeedFrom $rigorousseed $discoverseedfrom $discoverseedto)
  seedto=$(calculateSeedTo $rigorousseed $discoverseedfrom $discoverseedto)
  echo $(date): rigorousseed=${rigorousseed},seedfrom=${seedfrom},seedto=${seedto} >> $logfile

  for seed in $(seq $seedfrom $seedto)
  do
    outputfile2=${outputfileprefix2}_${seed}
    echo $(date): Running seed=${seed} >> $logfile
    if [ ! -s $outputfile2 ]
    then
      time ./run.sh $graphname 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $mult2 $numerator2 $denominator2 $solvestart $solveend $routingparam $kornparam $trafficfilename 0 $seed $suffix $npfile $pwfile $dp $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" > $outputfile2 &
      sleep 30
      wait
      echo $(date): Experiment done "("seed=$seed")" >> $logfile
      make=NOMAKE
    else
      echo $(date): Result already exists "("seed=$seed")" >> $logfile
    fi
  done

  combinedoutputfile2=${outputfileprefix2}_${seedfrom}_${seedto}
  if [ -e $combinedoutputfile2 ]
  then
    rm $combinedoutputfile2
  fi
  for seed in $(seq $seedfrom $seedto)
  do
    outputfile2=${outputfileprefix2}_${seed}
    cat $outputfile2 >> $combinedoutputfile2
  done
done

echo $(date): Collecting stats for ${outputfileprefix2} >> $logfile
./rigorous_aux_collect_n99fct_totaltraffic_from_multiple_stats.sh $outputfileprefix2 $rigorousseedfrom $rigorousseedto $discoverseedfrom $discoverseedto $mstart $mend ${outputfileprefix2}_summary > $tempoutputfile
n99fct2=$(cat $tempoutputfile | cut -d " " -f 1)
totaltraffic2=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fct2},totaltraffic=${totaltraffic2} >> $logfile

for rigorousseed in $(seq $rigorousseedfrom $rigorousseedto)
do
  seedfrom=$(calculateSeedFrom $rigorousseed $discoverseedfrom $discoverseedto)
  seedto=$(calculateSeedTo $rigorousseed $discoverseedfrom $discoverseedto)
  combinedoutputfile2=${outputfileprefix2}_${seedfrom}_${seedto}
  rm $combinedoutputfile2
done

# Calculate the cutoff point.
calculate_m() {
  awk -v x1=$1 -v y1=$2 -v x2=$3 -v y2=$4 'BEGIN {printf ((y2-y1)/(x2-x1))}'
}

calculate_b() {
  awk -v x=$1 -v y=$2 -v m=$3 'BEGIN {printf (y-m*x)}'
}

calculate_x_given_y() {
  awk -v y=$1 -v m=$2 -v b=$3 'BEGIN {printf ((y-b)/m)}'
}

echo $(date): Calculating the cutoff point >> $logfile
echo n99fct1=${n99fct1},totaltraffic1=${totaltraffic1},n99fct2=${n99fct2},totaltraffic2=${totaltraffic2} >> $logfile
m=$(calculate_m $totaltraffic1 $n99fct1 $totaltraffic2 $n99fct2)
b=$(calculate_b $totaltraffic1 $n99fct1 $m)
x=$(calculate_x_given_y $threshold $m $b)
echo m=${m},b=${b},y=${threshold},x=${x} >> $logfile

#echo Finished.
#echo $suffix $x
#echo $n99fct1 $threshold $n99fct2
echo ${x}

rm $tempoutputfile
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ >> $logfile
echo ================================================= >> $logfile
