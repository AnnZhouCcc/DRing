routing=su
k=3
date=831_fbs_rp_10
run_leafspine=false
run_fb_tms(){
    numerator=0
    denominator=10
    # for tm in {"skewed","uniform"}; do
    tm="uniform"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_${tm}.data"
    tm=fb_${tm}
    # for mult in 0 1; do
    mult=2
    for numerator in {1..8}; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 5
    done
    # done
    wait
    # done
}


run_fb_tms_rp(){
    numerator=0
    denominator=10
    # for tm in {"skewed","uniform"}; do
    tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_rand_placed_x48_y16_${tm}.data"
    tm=fb_${tm}_rp
    # for mult in 0 1; do
    mult=0
    for numerator in 2 4 6 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 5
    done
    # done
    wait
    # done
}


run_cs_skewed(){
    # mult=8
    numerator=0
    denominator=0
    tm="cs_skewed"
    C=768
    S=192
    tm=${tm}_${C}_${S}
    MAKE=NOMAKE
    for mult in 1 2; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 30
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    done
    wait
    for mult in 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 30
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    done
    wait
    mult=5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        for mult in 5 6; do
        sleep 30
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
        done
    fi
    sleep 30
    wait
    # done
}


run_a2a(){
    numerator=0
    denominator=0
    tm="a2a"
    # sr=192 #(x/10)% corresponding to 10% avg. utilization with 50ms simtime
    MAKE=NOMAKE 
    for sr in 64 96; do
    tm=a2a_${sr}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 5
    done
    wait
    for sr in 128 160; do
    tm=a2a_${sr}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 5
    done
    wait
    for sr in 192 224; do
    tm=a2a_${sr}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 5
    done
    wait
    # done
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
}

run_r2r_tms
# run_cs_skewed
# run_a2a
run_fb_tms_rp
# run_fb_tms
