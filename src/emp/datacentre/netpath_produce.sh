topology=rrg96-3
graphfile=graphfiles/ring_supergraph/new/rrg/snodes16/instance3_96_60.edgelist
numservers=3456
topologyname=RRG
name=netpath_produce_temporary_dir
values='0.01'
stime=200
mstart=50
mend=150
routing=su3
routingname=su
routingnumber=3
mode=equal
trafficmatrix=r2r0
trafficname=S2S_1_1_0_0
trafficparam=null
solvestart=0
solveend=0
solveinterval=0
computestart=0
computeend=0
computeinterval=0
precision=64
lpsolvermode=barriernocrossover

if [ ! -d $name ]
then
  mkdir $name
fi

suffix=${topology}_${routing}_${trafficmatrix}_${mode}
pwfile=pathweightfiles/${topology}/${routing}/pathweight_${topology}_${routing}_equal_${precision}.txt
netpathfile=null

seed=0
make=MAKE
tempoutputfile=${name}/netpath_produce_temporary
for value in $values
do
  ./discover_aux_fraction.sh $value > ${tempoutputfile}_${value}
  mult=$(cat ${tempoutputfile}_${value} | cut -d " " -f 1)
  numerator=$(cat ${tempoutputfile}_${value} | cut -d " " -f 2)
  denominator=$(cat ${tempoutputfile}_${value} | cut -d " " -f 3)
  echo value=${value},mult=${mult},numerator=${numerator},denominator=${denominator}

  time ./run.sh $topologyname 1 60 0 $graphfile $numservers 1 1 $make $trafficname $mult $numerator $denominator $solvestart $solveend $routingname $routingnumber $trafficparam 0 $seed ${topology}_$suffix $netpathfile $pwfile $precision $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" > ${name}/${topology}_${routing}_${mode}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
  #time ./run.sh $topologyname 1 64 16 $graphfile $numservers 1 1 $make $trafficname $mult $numerator $denominator $solvestart $solveend $routingname $routingnumber $trafficparam 0 $seed ${topology}_$suffix $netpathfile $pwfile $precision $mstart $mend $stime $solveinterval $computestart $computeend $computeinterval | grep -e "FCT" -e "topology" > ${name}/${topology}_${routing}_${mode}_${mult}_${numerator}_${denominator}_${stime}_${seed} &
  sleep 30
  make=NOMAKE
done
wait

for value in $values
do
  rm ${tempoutputfile}_${value}
done
