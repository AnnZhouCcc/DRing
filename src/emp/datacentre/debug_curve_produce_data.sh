runls=0
runrrgequal=1
runrrglppbr=0
rundringequal=0
rundringlppbr=0

topology=leafspine

name=jan29
values=''

stime=200
mstart=50
mend=150

routing=ecmp
routingname=ecmp
routingnumber=0
mode=equal

trafficmatrix=a2a
trafficname=A2A
trafficparam=null
solvestart=
solveend=
solveinterval=
computestart=
computeend=
computeinterval=

precision=64
lpsolvermode=barriernocrossover

if [ ! -d debug_curve_$name ]
then
  mkdir debug_curve_$name
fi

suffix=${routing}_${traffic}_${mode}
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
  ./discover_aux_fraction.sh $a > ${tempoutputfile}_${value}
  mult=$(cat $tempoutputfile | cut -d " " -f 1)
  numerator=$(cat $tempoutputfile | cut -d " " -f 2)
  denominator=$(cat $tempoutputfile | cut -d " " -f 3)

  time ./run.sh $topologyname 1 64 16 $graphfile $numservers 1 1 $make $trafficname $mult $numerator $denominator $solvestart $solveend $routingname $routingnumber $trafficparam 0 $seed leafspine_$suffix $netpathfile $pwfile $precision $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" -e "^queue" > debug_curve_${name}/${topology}_${mode}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
  sleep 30
  make=NOMAKE
done
wait

for value in $values
do
  rm ${tempoutputfile}_${value}
done
