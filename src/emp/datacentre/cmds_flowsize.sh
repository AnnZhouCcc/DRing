routing=fhi
k=0
date=714v4
run_leafspine=false
run_fb_tms(){
    mult=4
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_${tm}.data"
    tm=fb_${tm}
    # for mult in {1..4}; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${mult} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult} &
    # sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${mult} ${routing} ${k} ${tmfile} 10 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult} &
    fi
    wait
    done
    # done
}


run_fb_tms_rp(){
    mult=4
    # for mult in 1 2 3 4;
    # do
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_rand_placed_x48_y16_${tm}.data"
    tm=fb_${tm}_rp
    # for mult in {1..4}; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${mult} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult} &
    # sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${mult} ${routing} ${k} ${tmfile} 10 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult} &
    fi
    wait
    done
    # done
}


run_cs_skewed(){
    # for mult in 2 4 6; 
    # do
    mult=4
    tm="cs_skewed"
    C=768
    S=192
    tm=${tm}_${C}_${S}
    MAKE=MAKE
    # for mult in {1..4}; do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult} &
    # sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult} &
    if [ "$run_leafspine" = true ]; then
        sleep 30
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult} &
    fi
    wait
    # done
}


run_a2a(){
    tm="a2a"
    sr=96 #(x/10)% corresponding to 10% avg. utilization with 50ms simtime
    # tm=${tm}_${sr}
    MAKE=NOMAKE 
    # for sr in 64 96 128 160; do
    tm=a2a_${sr}
    # for k in 6 8 10 12 14 16;
    # do
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RANDOM ${sr} ${routing} ${k} ${sr} 0 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_sr${sr} &
    # sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_sr${sr} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_sr${sr} &
    fi
    wait
    # done
}


run_r2r_tms(){
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    mult=7
    inst=50 # need to change manually in code
    # for mult in 4 6 8 10; do
    # k=0
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${mult} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_inst${inst}_ii${mult} &
    # sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_inst${inst}_ii${mult} &
    if [ "$run_leafspine" = true ]; then
        sleep 30
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_inst${inst}_ii${mult} &
    fi
    wait
    # done
}


run_r2r_tms
run_cs_skewed
# run_a2a
run_fb_tms_rp
run_fb_tms
