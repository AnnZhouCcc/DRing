routing=su
k=2
rstag=su2
date=0517dringt50016to4su2


run_make(){
    numerator=1
    denominator=10
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    mult=0
    npfile="none"
    solve_starttime=0
    solve_endtime=0
    name=make
    dp=0
    pwfile="none"
    mstart=0
    mend=1
    stime=60
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${mstart}_${mend}_${stime} &
    wait
}


run_16to4(){
    MAKE=NOMAKE
    tm="16to4"
    C=768
    S=192
    npfile="none"
    dp=0
    pwfile="none"
    solve_starttime=0
    solve_endtime=0
    stime=500
    mstart=0
    mend=501

    denominator=0
    numerator=0
    for mult in 1 2 3 4; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait

    for mult in 5 6; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait

    for mult in 7; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait

    for mult in 8; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait

    for mult in 9; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait

    for mult in 10; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait

    for mult in 11; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait

    for mult in 12; do
    name=run1
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait
}


run_make
run_16to4
