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
    mstart=0
    mend=1
    stime=60
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${mstart}_${mend}_${stime} &
    wait
}


run_a2a(){
    MAKE=NOMAKE
    tm="a2a"
    topology=rrg
    denominator=0
    numerator=0
    npfile="none"
    dp=0
    name=test
    pwfile="none"
    solve_starttime=0
    solve_endtime=0
    stime=500

    mstart=0
    mend=501
    for sr in 700 750; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait
}


run_make
run_a2a
