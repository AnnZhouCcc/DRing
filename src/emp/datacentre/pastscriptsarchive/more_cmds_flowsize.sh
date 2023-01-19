routing=ecmp
k=0
date=911
run_leafspine=true


run_16_to_4(){
    numerator=0
    denominator=10
    tm="css_16_to_4"
    C=768
    S=192
    MAKE=NOMAKE
    # for mult in 1 2 3; do
    mult=2
    for numerator in 8 9; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    # if [ "$run_leafspine" = true ]; then
        # time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
        # sleep 30
    # fi
    done
    wait
    # done
}

run_4_to_16(){
    numerator=0
    denominator=10
    tm="css_4_to_16"
    C=192
    S=768
    MAKE=NOMAKE
    # for mult in 1 2 3; do
    mult=2
    for numerator in 2 4 6 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    done
    wait
    for numerator in 2 4 6 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    done
    wait
    for numerator in 2 4 6 8; do
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    # sleep 30
    done
    wait
    # done
}

run_48_to_4(){
    numerator=0
    denominator=10
    tm="css_48_to_4"
    C=2304
    S=192
    MAKE=NOMAKE
    # for mult in 4 6 8; do
    mult=4
    for numerator in {1..4}; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    done
    wait
    for numerator in 2 4 6 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    done
    wait
    # done
    mult=2
    denominator=10
    for numerator in 5 7; do 
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    done
    wait
    # done
}


run_60_to_1(){
    numerator=0
    denominator=10
    tm="css_60_to_1"
    C=2880
    S=48
    MAKE=NOMAKE
    # for mult in 1 2 3; do
    mult=0
    for numerator in {5..8}; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 30
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 30
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME_REPEAT ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
        sleep 30
    fi
    done
    wait
    # done
}


run_1_to_60(){
    numerator=0
    denominator=10
    tm="css_1_to_60"
    C=48
    S=2880
    MAKE=NOMAKE
    # for mult in 1 2; do
    mult=1
    for numerator in 5 6 7; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    done
    mult=0
    for numerator in 7 8 9; do
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    done
    wait
    # done
}


run_mix_4(){
    numerator=0
    denominator=10
    tm="mix_4"
    MAKE=NOMAKE
    # for mult in 4 6 8; do
    # mult=4
    # for numerator in {1..4}; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 4 0 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 30
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 4 0 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 30
    # done
    # wait
    mult=11
    for numerator in 1 2; do
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 4 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
        sleep 30
    fi
    done
    wait
    for numerator in 3 4; do
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 4 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
        sleep 30
    fi
    done
    wait
}


run_mix_8(){
    numerator=0
    denominator=0
    tm="mix_8"
    MAKE=NOMAKE
    for mult in {1..4}; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 8 0 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    done
    wait
    for mult in {1..4}; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 8 0 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    done
    wait
    for mult in 2 4 6; do
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 8 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    done
    wait
    for mult in 8 10; do
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 8 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    done
    wait
}


run_r2r_tms(){
    numerator=1
    denominator=10
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    mult=0
    inst=50 # need to change manually in code
    # for mult in 4 6; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 30
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    # done
    wait
    # done
}


run_r2r_tms
run_mix_4
run_60_to_1
# run_48_to_4
# run_4_to_16
run_1_to_60
run_16_to_4
# run_mix_8
