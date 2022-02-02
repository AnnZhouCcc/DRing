routing=su
k=2
rstag=su2
date=0202su22v1


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
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name} &
    wait
}


run_clusterb(){
    MAKE=NOMAKE
    tm="clusterb"
    tmfile="b"
    mult=0
    denominator=2
    numerator=1
    topology=rrg
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"
    name=delaytm
    dp=3
    compute_starttime=30400
    compute_endtime=34000
    solve_starttime=34000
    solve_endtime=34600
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=${solve_starttime}
    compute_endtime=${solve_endtime}
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=equal
    type=eq
    pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait

    mult=1
    denominator=0
    numerator=0
    topology=rrg
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"
    name=delaytm
    dp=3
    compute_starttime=30400
    compute_endtime=34000
    solve_starttime=34000
    solve_endtime=34600
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=${solve_starttime}
    compute_endtime=${solve_endtime}
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=equal
    type=eq
    pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait

    mult=1
    denominator=2
    numerator=1
    compute_starttime=30400
    compute_endtime=34000
    solve_starttime=34000
    solve_endtime=34600
    name=delaytm
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=${solve_starttime}
    compute_endtime=${solve_endtime}
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=equal
    type=eq
    pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait

    mult=2
    denominator=0
    numerator=0
    compute_starttime=30400
    compute_endtime=34000
    solve_starttime=34000
    solve_endtime=34600
    name=delaytm
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=${solve_starttime}
    compute_endtime=${solve_endtime}
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=equal
    type=eq
    pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait

    mult=2
    denominator=2
    numerator=1
    compute_starttime=30400
    compute_endtime=34000
    solve_starttime=34000
    solve_endtime=34600
    name=delaytm
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=${solve_starttime}
    compute_endtime=${solve_endtime}
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=equal
    type=eq
    pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait

    mult=3
    denominator=0
    numerator=0
    compute_starttime=30400
    compute_endtime=34000
    solve_starttime=34000
    solve_endtime=34600
    name=delaytm
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=${solve_starttime}
    compute_endtime=${solve_endtime}
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=equal
    type=eq
    pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait

    mult=3
    denominator=2
    numerator=1
    compute_starttime=30400
    compute_endtime=34000
    solve_starttime=34000
    solve_endtime=34600
    name=delaytm
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=optimaltm
    compute_starttime=${solve_starttime}
    compute_endtime=${solve_endtime}
    type=lp1
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    type=lp2
    pwfile="pathweightfiles/${topology}/${name}/pathweights_${type}_${topology}_${rstag}_${tm}_${compute_starttime}_${compute_endtime}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    name=equal
    type=eq
    pwfile="pathweightfiles/${topology}/${name}/pathweight_${topology}_${rstag}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} CLUSTERX ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${type} &
    sleep 5
    wait
}


run_make
run_clusterb
