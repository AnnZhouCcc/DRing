runls=1
runrrgequal=0
runrrglppbr=0
rundringequal=0
rundringlppbr=0
seedfrom=0
seedto=4
mult=0
numerator=65125
denominator=100000
name=jan23
stime=200
mstart=50
mend=150

if [ ! -d sanity_check_$name ]
then
  mkdir sanity_check_$name
fi

if [ $runls -gt 0 ]
then
  make=MAKE
  for seed in $(seq $seedfrom $seedto)
  do
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 $make A2A $mult $numerator $denominator 0 0 ecmp 0 null 0 $seed leafspine_ecmp_a2a_equal netpathfiles/netpath_ecmp_leafspine.txt pathweightfiles/leafspine/ecmp/pathweight_leafspine_ecmp_equal_64.txt 64 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" -e "^queue" > sanity_check_${name}/leafspine_equal_${mult}_${numerator}_${denominator}_${stime}_${seed} &
    sleep 30
    make=NOMAKE
  done
  wait
fi

if [ $runrrgequal -gt 0 ] 
then
  make=MAKE
  for seed in $(seq $seedfrom $seedto)
  do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 $make A2A $mult $numerator $denominator 0 0 ecmp 0 null 0 $seed rrg_ecmp_a2a_equal netpathfiles/netpath_ecmp_rrg.txt pathweightfiles/rrg/ecmp/pathweight_rrg_ecmp_equal_64.txt 64 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" -e "^queue" > sanity_check_${name}/rrg_equal_${mult}_${numerator}_${denominator}_${stime}_${seed} &
    sleep 30
    make=NOMAKE
  done
  wait
fi

if [ $runrrglppbr -gt 0 ] 
then
  make=MAKE
  for seed in $(seq $seedfrom $seedto)
  do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 $make A2A $mult $numerator $denominator 0 0 ecmp 0 null 0 $seed rrg_ecmp_a2a_lppbr netpathfiles/netpath_ecmp_rrg.txt pathweightfiles/rrg/ecmp/a2a/pathweight_rrg_ecmp_a2a_lp1_barriernocrossover_64.txt 64 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" -e "^queue" > sanity_check_${name}/rrg_lppbr_${mult}_${numerator}_${denominator}_${stime}_${seed} &
    sleep 30
    make=NOMAKE
  done
  wait
fi

if [ $rundringequal -gt 0 ] 
then
  make=MAKE
  for seed in $(seq $seedfrom $seedto)
  do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 $make A2A $mult $numerator $denominator 0 0 ecmp 0 null 0 $seed dring_ecmp_a2a_equal netpathfiles/netpath_ecmp_dring.txt pathweightfiles/dring/ecmp/pathweight_dring_ecmp_equal_64.txt 64 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" -e "^queue" > sanity_check_${name}/dring_equal_${mult}_${numerator}_${denominator}_${stime}_${seed} &
    sleep 30
    make=NOMAKE
  done
  wait
fi

if [ $rundringlppbr -gt 0 ] 
then
  make=MAKE
  for seed in $(seq $seedfrom $seedto)
  do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 $make A2A $mult $numerator $denominator 0 0 ecmp 0 null 0 $seed dring_ecmp_a2a_lppbr netpathfiles/netpath_ecmp_dring.txt pathweightfiles/dring/ecmp/a2a/pathweight_dring_ecmp_a2a_lp1_barriernocrossover_64.txt 64 $mstart $mend $stime 0 0 0 0 | grep -e "FCT" -e "topology" -e "^queue" > sanity_check_${name}/dring_lppbr_${mult}_${numerator}_${denominator}_${stime}_${seed} &
    sleep 30
    make=NOMAKE
  done
  wait
fi
