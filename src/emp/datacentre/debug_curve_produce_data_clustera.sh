topology=$1

name=jan29_clustera
values='2.675 5.35 8.025 10.7 13.375 16.05 18.725 21.4'

stime=1000
mstart=250
mend=750

routing=$2
routingname=$3
routingnumber=$4
mode=$5

trafficmatrix=clustera
trafficname=CLUSTERX
trafficparam=a
solvestart=0
solveend=84600
solveinterval=1800
computestart=0
computeend=84600
computeinterval=1800

precision=64
lpsolvermode=barriernocrossover

if [ ! -d debug_curve_$name ]
then
  mkdir debug_curve_$name
fi

suffix=${routing}_${trafficmatrix}_${mode}
netpathfile=netpathfiles/netpath_${routing}_${topology}.txt

if [ $topology = "rrg" ]
then
  topologyname=RRG
  graphfile=graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist
  numservers=3072
elif [ $topology = "dring" ]
then
  topologyname=RRG
  graphfile=graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist
  numservers=2988
elif [ $topology = "leafspine" ]
then
  topologyname=LEAFSPINE
  graphfile=null
  numservers=3072
else
  echo topology $topology not recognized.
fi

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
  elif [ $mode = "lpdbr-optimal" ] || [ $mode = "lpdbr-nox-optimal" ] || [ $mode = "lpdbr-nox-delay" ] || [ $mode = "lpdbr-delay" ]
  then
    pwfile=pathweightfiles/${topology}/${routing}/${trafficmatrix}/pathweight_pbr1_${topology}_${routing}_${trafficmatrix}_lp1_${lpsolvermode}_
  else
    echo mode $mode not recognized.
  fi
fi

seed=0
make=MAKE
tempoutputfile=debug_curve_temp
for value in $values
do
  ./discover_aux_fraction.sh $value > ${tempoutputfile}_${value}
  mult=$(cat ${tempoutputfile}_${value} | cut -d " " -f 1)
  numerator=$(cat ${tempoutputfile}_${value} | cut -d " " -f 2)
  denominator=$(cat ${tempoutputfile}_${value} | cut -d " " -f 3)
  echo value=${value},mult=${mult},numerator=${numerator},denominator=${denominator}

  time ./run.sh $topologyname 1 64 16 $graphfile $numservers 1 1 $make $trafficname $mult $numerator $denominator $solvestart $solveend $routingname $routingnumber $trafficparam 0 $seed $topology_$suffix $netpathfile $pwfile $precision $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" -e "^queue" > debug_curve_${name}/${topology}_${routing}_${mode}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
  sleep 30
  make=NOMAKE
done
wait

for value in $values
do
  rm ${tempoutputfile}_${value}
done