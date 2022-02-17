routing=ecmp
k=0
rstag=ecmp
date=0217test


run_make(){
    numerator=1
    denominator=10
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    mult=0
    topology=rrg
    npfile="none"
    solve_starttime=0
    solve_endtime=0
    name=make
    dp=0
    pwfile="none"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name} &
    wait
}


run_test(){
    MAKE=NOMAKE
    tm="testrandom"
    topology=rrg
    name=1536
    mstart=10
    mend=55
    stime=60
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} TEST 0 0 0 0 0 ${routing} ${k} 0 0 3 rrg_${routing}_80_64_1 "none" "none" 0 ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_${name} &
    sleep 5
    wait
}


run_make
run_test
