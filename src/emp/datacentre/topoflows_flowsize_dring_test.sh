routing=racke2
k=0
rstag=racke2
date=dringa2afct


run_make(){
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    seed=3
    mult=0
    numerator=0
    denominator=0
    npfile="none"
    pwfile="none"
    dp=0
    solvestart=0
    solveend=0
    solveinterval=0
    computestart=0
    computeend=0
    computeinterval=0
    mstart=0
    mend=1
    stime=60
    name=make
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${C} ${S} ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${computeinterval}_${solveinterval}_${stime} &
    sleep 5
    wait
}


run_a2a(){
    MAKE=NOMAKE
    tm="a2a"
    npfile=netpathfiles/netpath_${rstag}_dring.txt
    pwfile=pathweightfiles/dring/${rstag}/pathweight_dring_${rstag}_a2a_lp1_64.txt
    stime=200
    mstart=50
    mend=150
    #numerator=15
    denominator=100
    mult=0
    name=a2a
    for numerator in 5 10; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
}


run_make
run_a2a
