routing=su
k=2
rstag=su2
date=0119


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
    name=make
    dp=0
    pwfile="none"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    wait
}


run_clusterb(){
    MAKE=NOMAKE
    tm="clusterb"
    tmfile="b"
    mult=2
    topology=rrg
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"
    name=delaytm
    # name=equal
    dp=3
    compute_starttime=59600
    compute_endtime=63200
    solve_starttime=63200
    solve_endtime=66800
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    # pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=63200
    compute_endtime=66800
    solve_starttime=63200
    solve_endtime=66800
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait
}


# run_make
run_clusterb
