routing=racke0
k=0
rstag=racke0
date=dringa2aracke0


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


run_equal(){
    MAKE=NOMAKE
    tm="a2a"
    npfile=netpathfiles/netpath_${rstag}_dring.txt
    pwfile=pathweightfiles/dring/${rstag}/pathweight_dring_${rstag}_equal_64.txt
    stime=200
    mstart=50
    mend=150
    denominator=100
    mult=0
    for numerator in 2 4 6 8; do
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done

    for numerator in 10 12 14 16; do
    for run in 0 1 2 3 4; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 5 6 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done

    for numerator in 18 20; do
    for run in 0 1 2 3; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 4 5 6; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 7 8 9; do
    name=equal_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done
}


run_weighted(){
    MAKE=NOMAKE
    tm="a2a"
    npfile=netpathfiles/netpath_${rstag}_dring.txt
    pwfile=pathweightfiles/dring/${rstag}/pathweight_dring_${rstag}_weighted_64.txt
    stime=200
    mstart=50
    mend=150
    denominator=100
    mult=0
    for numerator in 2 4 6 8 10; do
    for run in 0 1 2 3 4 5 6 7 8 9; do
    name=weighted_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done

    for numerator in 12 14 16 18 20; do
    for run in 0 1 2 3 4; do
    name=weighted_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 5 6 7 8 9; do
    name=weighted_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done

    for numerator in 22; do
    for run in 0 1 2 3; do
    name=weighted_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 4 5 6; do
    name=weighted_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 7 8 9; do
    name=weighted_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done
}

#ocean2
run_lp(){
    MAKE=NOMAKE
    tm="a2a"
    npfile=netpathfiles/netpath_${rstag}_dring.txt
    pwfile=pathweightfiles/dring/${rstag}/pathweight_dring_${rstag}_a2a_lp1_64.txt
    stime=200
    mstart=50
    mend=150
    denominator=10
    mult=0
    for numerator in 2; do
    for run in 0 1 2 3 4; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 5 6 7 8 9; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done

    for numerator in 4; do
    for run in 0 1 2 3; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 4 5 6; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 7 8 9; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done

    for numerator in 6; do
    for run in 0 1; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 2 3; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 4 5; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 6 7; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    for run in 8 9; do
    name=lp_run${run}
    seed=${run}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} A2A ${mult} ${numerator} ${denominator} 0 0 ${routing} ${k} 0 0 ${seed} dring_${routing}_80_64_1 ${npfile} ${pwfile} 0 ${mstart} ${mend} ${stime} 0 0 0 0 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${stime} &
    sleep 5
    done
    wait
    done
}


run_make
#run_equal
#run_weighted
run_lp
