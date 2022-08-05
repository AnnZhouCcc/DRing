routing=ecmp
k=0
rstag=ecmp
date=lsa2aecmp2


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
    tm="a2a"
    npfile="netpathfiles/netpath_ecmp_leafspine.txt"
    pwfile="pathweightfiles/leafspine/ecmp/pathweight_leafspine_ecmp_equal_64.txt"
    stime=200
    mstart=50
    mend=150
    denominator=1000
    mult=0
    for numerator in 3 6 9 12 15 18 21 24 27 30 33 36; do
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done
}


run_equal2(){
    MAKE=NOMAKE
    tm="a2a"
    npfile="none"
    pwfile="none"
    stime=200
    mstart=50
    mend=150
    denominator=1000
    mult=0
    for numerator in 3 6 9 12 15 18 21 24 27 30 33 36; do
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=equal2_run${run}
    seed=${run}
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done
}


run_make
# run_equal
run_equal2
