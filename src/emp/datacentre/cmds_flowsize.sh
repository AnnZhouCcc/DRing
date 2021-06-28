routing=fhi
date=626
lan=74565
run_fb_tms(){
    mult=1
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_${tm}.data"
    tm=fb_${tm}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${mult} ${tmfile} 10 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/dring_${routing}_${tm}_${date}_ii${mult}_${lan} &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/rrg_${routing}_${tm}_${date}_ii${mult}_${lan} &
    sleep 5
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${mult} ${tmfile} 10 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${lan} &
    wait
    done
}


run_fb_tms_rp(){
    # mult=4
    for mult in 1 2 3 4;
    do
    for tm in {"skewed","uniform"};
    do
    #tm="skewed"
    tmfile="graphfiles/ring_supergraph/ls_rand_placed_x48_y16_${tm}.data"
    tm=fb_${tm}_rp
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${mult} ${tmfile} 10 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/dring_${routing}_${tm}_${date}_ii${mult}_${lan}_smallersize &
    sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/rrg_${routing}_${tm}_${date}_ii${mult}_${lan}_smallersize &
    sleep 5
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${mult} ${tmfile} 10 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${lan}_smallersize &
    wait
    done
    done
}


run_cs_skewed(){
    # for mult in 6 7; 
    # do
    mult=7
    tm="cs_skewed"
    C=768
    S=192
    tm=${tm}_${C}_${S}
    MAKE=MAKE
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${C} ${S} 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/dring_${routing}_${tm}_${date}_ii${mult}_${lan} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/rrg_${routing}_${tm}_${date}_ii${mult}_${lan} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${C} ${S} 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${lan} &
    wait
    # done
}


run_a2a(){
    tm="a2a"
    # sr=64 #(x/10)% corresponding to 10% avg. utilization with 50ms simtime
    # sr=48
    # tm=${tm}_${sr}
    MAKE=NOMAKE 
    for sr in 24 32 40;
    do
    tm=a2a_${sr}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RANDOM 0 ${sr} 0 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/dring_${routing}_${tm}_${date}_sr${sr}_${lan} &
    # sleep 5
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM 0 ${sr} 0 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/rrg_${routing}_${tm}_${date}_sr${sr}_${lan} &
    # sleep 5
    # time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM 0 ${sr} 0 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results_${date}/ls_${tm}_${date}_sr${sr}_${lan} &
    wait
    done
}


run_r2r_tms(){
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    mult=1
    inst=1 # need to change manually in code
    # for mult in {7..11};
    # do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${mult} ${C} ${S} 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/dring_${routing}_${tm}_${date}_inst${inst}_ii${mult}_${lan} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/rrg_${routing}_${tm}_${date}_inst${inst}_ii${mult}_${lan} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${C} ${S} 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results_${date}/ls_${tm}_${date}_inst${inst}_ii${mult}_${lan} &
    wait
    # done
}


run_r2r_tms
# run_cs_skewed
run_a2a
# run_fb_tms_rp
# run_fb_tms
