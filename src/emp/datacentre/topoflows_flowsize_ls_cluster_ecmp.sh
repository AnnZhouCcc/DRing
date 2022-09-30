routing=ecmp
k=0
rstag=ecmp
date=lsclusterbecmp


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
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${C} ${S} ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${computeinterval}_${solveinterval}_${stime} &
    sleep 5
    wait
}


run_equal(){
    MAKE=NOMAKE
    tm="cluster_b"
    tmfile="b"
    npfile="netpathfiles/netpath_ecmp_leafspine.txt"
    pwfile="pathweightfiles/leafspine/ecmp/pathweight_leafspine_ecmp_equal_64.txt"
    stime=400
    mstart=100
    mend=300
    solve_starttime=0
    solve_endtime=86400
    solve_interval=1800

    numerator=0
    denominator=0
    for mult in 1 2; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} ${solve_interval} 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait

    mult=0
    denominator=10
    for numerator in 2 4 6 8; do
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} ${solve_interval} 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    done
    wait

    mult=1
    denominator=10
    for numerator in 2 4; do
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} ${solve_interval} 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    done
    wait

    mult=1
    denominator=10
    for numerator in 6 8; do
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} ${solve_interval} 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    done
    wait

    mult=2
    denominator=10
    numerator=2
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} ${solve_interval} 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
}


run_make
run_equal
