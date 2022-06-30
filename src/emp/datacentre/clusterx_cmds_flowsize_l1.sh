routing=su
k=2
rstag=su2
date=0630prelimt200clusterbsu2


run_make(){
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    topology=rrg
    mult=0
    numerator=1
    denominator=10
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
    time ./run_clusterx_small_interval.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${solvestart}_${solveend}_${solveinterval}_${computestart}_${computeend}_${computeinterval}_${mstart}_${mend}_${stime} &
    wait
}


run_cluster(){
    MAKE=NOMAKE
    tm="cluster_b"
    tmfile="b"
    npfile="netpathfiles/netpath_su2_rrg.txt"
    dp=3

    solve_starttime=7200
    solve_endtime=86400
    solve_interval=1800   

    stime=200
    mstart=0
    mend=201

    numerator=0
    denominator=0
    mult=1

    compute_starttime=0
    compute_endtime=0
    compute_interval=0 
    name=optimallp1
    pwfile="pathweightfiles/rrg/su2/7200_0_1800/optimallp1/pathweight_lp1_rrg_su2_clusterb_"
    time ./run_clusterx_small_interval.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${solvestart}_${solveend}_${solveinterval}_${computestart}_${computeend}_${computeinterval}_${mstart}_${mend}_${stime} &
    sleep 5

    compute_starttime=0
    compute_endtime=84600
    compute_interval=7200 
    name=delaylp1
    pwfile="pathweightfiles/rrg/su2/7200_0_1800/delaylp1/pathweight_lp1_rrg_su2_clusterb_"
    time ./run_clusterx_small_interval.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${solvestart}_${solveend}_${solveinterval}_${computestart}_${computeend}_${computeinterval}_${mstart}_${mend}_${stime} &
    sleep 5
    
    name=delaylp2
    pwfile="pathweightfiles/rrg/su2/7200_0_1800/delaylp2/pathweight_lp2_rrg_su2_clusterb_"
    time ./run_clusterx_small_interval.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solvestart} ${solveend} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} ${solveinterval} ${computestart} ${computeend} ${computeinterval} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${solvestart}_${solveend}_${solveinterval}_${computestart}_${computeend}_${computeinterval}_${mstart}_${mend}_${stime} &
    sleep 5
}


run_make
run_cluster
