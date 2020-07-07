routing=kdisjoint
run_fb_tms(){
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_${tm}.data"
    tm=fb_${tm}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${tmfile} 10 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results/dring_${routing}_${tm} &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results/rrg_${routing}_${tm} &
    sleep 5
    #time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${tmfile} 10 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results/ls_${tm} &
    #wait
    done
}


run_fb_tms_rp(){
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_rand_placed_x48_y16_${tm}.data"
    tm=fb_${tm}_rp
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${tmfile} 10 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results/dring_${routing}_${tm} &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results/rrg_${routing}_${tm} &
    sleep 5
    #time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${tmfile} 10 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results/ls_${tm} &
    #wait
    done
}


run_cs_skewed(){
    tm="cs_skewed"
    C=768
    S=192
    tm=${tm}_${C}_${S}
    MAKE=MAKE
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${C} ${S} 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results/dring_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${C} ${S} 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results/rrg_${routing}_${tm} &
    #sleep 30
    #time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${C} ${S} 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results/ls_${tm} &
    wait
}


run_a2a(){
    tm="a2a"
    sr=64 #(x/10)% corresponding to 10% avg. utilization with 50ms simtime
    tm=${tm}_${sr}
    MAKE=NOMAKE
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RANDOM ${sr} 0 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results/dring_${routing}_${tm} &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} 0 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results/rrg_${routing}_${tm} &
    sleep 5
    #time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} 0 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results/ls_${tm} &
    #wait
}


run_r2r_tms(){
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${C} ${S} 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results/dring_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${C} ${S} 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results/rrg_${routing}_${tm} &
    sleep 30
    #time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${C} ${S} 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results/ls_${tm} &
    #wait
}

#run_r2r_tms
run_cs_skewed
#run_a2a
#run_fb_tms_rp
#run_fb_tms
