routing=s2
run_fb_tms(){
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_x40_y24_${tm}.data"
    tm=fb_${tm}
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/double_ring/instance1_88_64.edgelist 2536 1 1 MAKE FILE ${tmfile} 10 3 dring_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/dring_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/rrg/instance1_88_64.edgelist 2560 1 1 MAKE FILE ${tmfile} 10 3 rrg_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/rrg_${routing}_${tm} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 24 null 2560 1 1 MAKE FILE ${tmfile} 10 3 ls_flowsize_88_64_1 | grep "FCT" > fct_results/x40_y24/ls_${tm} &
    wait
    done
}


run_fb_tms_rp(){
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_rand_placed_x40_y24_${tm}.data"
    tm=fb_${tm}_rp
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/double_ring/instance1_88_64.edgelist 2536 1 1 MAKE FILE ${tmfile} 10 3 dring_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/dring_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/rrg/instance1_88_64.edgelist 2560 1 1 MAKE FILE ${tmfile} 10 3 rrg_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/rrg_${routing}_${tm} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 24 null 2560 1 1 MAKE FILE ${tmfile} 10 3 ls_flowsize_88_64_1 | grep "FCT" > fct_results/x40_y24/ls_${tm} &
    wait
    done
}


run_cs_skewed(){
    tm="cs_skewed"
    C=640
    S=160
    tm=${tm}_${C}_${S}
    MAKE=MAKE
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/double_ring/instance1_88_64.edgelist 2536 1 1 ${MAKE} FEW_TO_SOME ${C} ${S} 3 dring_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/dring_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/rrg/instance1_88_64.edgelist 2560 1 1 ${MAKE} FEW_TO_SOME ${C} ${S} 3 rrg_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/rrg_${routing}_${tm} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 24 null 2560 1 1 ${MAKE} FEW_TO_SOME ${C} ${S} 3 ls_flowsize_88_64_1 | grep "FCT" > fct_results/x40_y24/ls_${tm} &
    wait
}


run_a2a(){
    tm="a2a"
    sr=152 #(x/10)% sampled, chosen so that avg. rate per host = 25% line rate
    tm=${tm}_${sr}
    MAKE=MAKE
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/double_ring/instance1_88_64.edgelist 2536 1 1 ${MAKE} RANDOM ${sr} 0 3 dring_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/dring_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/rrg/instance1_88_64.edgelist 2560 1 1 ${MAKE} RANDOM ${sr} 0 3 rrg_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/rrg_${routing}_${tm} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 24 null 2560 1 1 ${MAKE} RANDOM ${sr} 0 3 ls_flowsize_88_64_1 | grep "FCT" > fct_results/x40_y24/ls_${tm} &
    wait
}


run_r2r_tms(){
    tm="r2r"
    C=40
    S=40
    MAKE=MAKE
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/double_ring/instance1_88_64.edgelist 2536 1 1 ${MAKE} RACK_TO_RACK ${C} ${S} 3 dring_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/dring_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 64 24 graphfiles/ring_supergraph/rrg/instance1_88_64.edgelist 2560 1 1 ${MAKE} RACK_TO_RACK ${C} ${S} 3 rrg_${routing}_88_64_1 | grep "FCT" > fct_results/x40_y24/rrg_${routing}_${tm} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 24 null 2560 1 1 ${MAKE} RACK_TO_RACK ${C} ${S} 3 ls_flowsize_88_64_1 | grep "FCT" > fct_results/x40_y24/ls_${tm} &
    wait
}

#run_a2a
#run_r2r_tms
run_cs_skewed
#run_fb_tms_rp
#run_fb_tms
