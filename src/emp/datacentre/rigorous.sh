#!/bin/bash
# Set parameters.
topology=$1
routing=$2
trafficmatrix=a2a
mode=$3
p1=$4
p2=$5
threshold=5
stime=200
mstart=50
mend=150
precision=64

npfile=netpathfiles/netpath_${routing}_${topology}.txt

if [ $mode = "equal" ]
then
  pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_equal_${precision}.txt
elif [ $mode = "weighted" ]
then
  pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_weighted_${precision}.txt
elif [ $mode = "lppbr" ]
then
  pwfile=pathweightfiles/${topology}/${routing}/${trafficmatrix}/pathweight_${topology}_${routing}_${trafficmatrix}_lp1_barrierwithcrossover_${precision}.txt
elif [ $mode = "lpdbr" ]
then
  pwfile=pathweightfiles/${topology}/${routing}/${trafficmatrix}/pathweight_pbr1_${topology}_${routing}_${trafficmatrix}_lp1_barrierwithcrossover_${precision}.txt
else
  echo mode $mode not recognized.
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

# Check the directory and logfile are present.
dir=discover_${topology}_${routing}_${trafficmatrix}_${mode}
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
suffix=${topology}_${routing}_${trafficmatrix}_${mode}
tempoutputfile=${dir}/${suffix}_output
make=MAKE
seedfrom=0
seedto=9

# Run experiments for p1.
./discover_aux_fraction.sh $p1 > $tempoutputfile
mult1=$(cat $tempoutputfile | cut -d " " -f 1)
numerator1=$(cat $tempoutputfile | cut -d " " -f 2)
denominator1=$(cat $tempoutputfile | cut -d " " -f 3)

echo $(date): Run experiment for p1 >> $logfile
echo mult=${mult1},numerator=${numerator1},denominator=${denominator1} >> $logfile

for seed in $(seq $seedfrom $seedto)
do
  outputfile1=${dir}/${mult1}_${numerator1}_${denominator1}_${stime}_${seed}
  echo $(date): Running seed=${seed}, outputting to ${outputfile1} >> $logfile
  if [ ! -s $outputfile1 ]
  then
    time ./run.sh $graphname 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $mult1 $numerator1 $denominator1 0 0 $routingparam $kornparam 0 0 $seed $suffix $npfile $pwfile 0 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" > $outputfile1 &
    sleep 30
    wait
    echo $(date): Experiment done >> $logfile
    make=NOMAKE
  else
    echo $(date): Result already exists >> $logfile
  fi
done

outputfileprefix1=${dir}/${mult1}_${numerator1}_${denominator1}_${stime}_
echo $(date): Collecting stats for ${outputfileprefix1} >> $logfile
./rigorous_aux_collect_n99fct_totaltraffic_from_multiple_stats.sh $outputfileprefix1 $seedfrom $seedto $mstart $mend ${outputfileprefix1}summary > $tempoutputfile
n99fct1=$(cat $tempoutputfile | cut -d " " -f 1)
totaltraffic1=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fct1},totaltraffic=${totaltraffic1} >> $logfile

# Run experiments for p2.
./discover_aux_fraction.sh $p2 > $tempoutputfile
mult2=$(cat $tempoutputfile | cut -d " " -f 1)
numerator2=$(cat $tempoutputfile | cut -d " " -f 2)
denominator2=$(cat $tempoutputfile | cut -d " " -f 3)

echo $(date): Run experiment for p2 >> $logfile
echo mult=${mult2},numerator=${numerator2},denominator=${denominator2} >> $logfile

for seed in $(seq $seedfrom $seedto)
do
  outputfile2=${dir}/${mult2}_${numerator2}_${denominator2}_${stime}_${seed}
  echo $(date): Running seed=${seed}, outputting to ${outputfile2} >> $logfile
  if [ ! -s $outputfile2 ]
  then
    time ./run.sh $graphname 1 64 16 $graphfile $numservers 1 1 $make $trafficmatrixparam $mult2 $numerator2 $denominator2 0 0 $routingparam $kornparam 0 0 $seed $suffix $npfile $pwfile 0 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" > $outputfile2 &
    sleep 30
    wait
    echo $(date): Experiment done >> $logfile
    make=NOMAKE
  else
    echo $(date): Result already exists >> $logfile
  fi
done

outputfileprefix2=${dir}/${mult2}_${numerator2}_${denominator2}_${stime}_
echo $(date): Collecting stats for ${outputfileprefix2} >> $logfile
./rigorous_aux_collect_n99fct_totaltraffic_from_multiple_stats.sh $outputfileprefix2 $seedfrom $seedto $mstart $mend ${outputfileprefix2}summary > $tempoutputfile
n99fct2=$(cat $tempoutputfile | cut -d " " -f 1)
totaltraffic2=$(cat $tempoutputfile | cut -d " " -f 2)
echo $(date): n99fct=${n99fct2},totaltraffic=${totaltraffic2} >> $logfile

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

echo Finished.
echo $suffix $x
echo $n99fct1 $threshold $n99fct2

rm $tempoutputfile
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ >> $logfile
echo ================================================= >> $logfile
