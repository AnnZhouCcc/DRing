routing=ecmp
k=0
rstag=ecmp
date=0722test


run_make(){
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
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
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${computeinterval}_${solveinterval}_${stime} &
    sleep 5
    wait
}


run_a2a(){
    MAKE=NOMAKE
    tm="a2a"
    npfile="netpathfiles/netpath_ecmp_leafspine.txt"
    pwfile="pathweightfiles/leafspine/ecmp/pathweight_leafspine_ecmp_equal_64.txt"
    stime=100
    mstart=25
    mend=75
    numerator=1
    denominator=2
    mult=1
    name=a2a
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    wait
}


run_test1(){
    MAKE=NOMAKE
    tm="r2r"
    C=48
    S=48
    npfile="netpathfiles/netpath_ecmp_leafspine.txt"
    pwfile="pathweightfiles/leafspine/ecmp/pathweight_leafspine_ecmp_equal_64.txt"
    dp=0
    solvestart=0
    solveend=0
    solveinterval=0
    computestart=0
    computeend=0
    computeinterval=0
    stime=60
    mstart=10
    mend=40
    numerator=0
    denominator=0
    mult=1
    name=test1
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${computeinterval}_${solveinterval}_${stime} &
    sleep 5
    wait
}


run_test2(){
    MAKE=NOMAKE
    tm="cluster_b"
    tmfile="b"
    npfile="netpathfiles/netpath_ecmp_leafspine.txt"
    pwfile="pathweightfiles/leafspine/ecmp/pathweight_leafspine_ecmp_equal_64.txt"
    dp=0
    solvestart=7200
    solveend=86400
    solveinterval=1800
    computestart=0
    computeend=86400
    computeinterval=7200
    stime=200
    mstart=50
    mend=150
    numerator=1
    denominator=10
    mult=0
    name=test2
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${tmfile} 10 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${computeinterval}_${solveinterval}_${stime} &
    sleep 5
    wait
}


run_make
run_a2a
# run_test1
# run_test2
