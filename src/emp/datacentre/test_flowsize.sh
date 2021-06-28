routing=s3
date=628
lan=894784
largemult=3
run_cs_skewed(){
    mult=7
    tm="cs_skewed"
    C=768
    S=192
    tm=${tm}_${C}_${S}
    MAKE=MAKE
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FEW_TO_SOME ${mult} ${C} ${S} 3 dring_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/dring_${routing}_${tm}_${date}_ii${mult}_${lan}_largemult${largemult} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep "FCT" > fct_results_${date}/rrg_${routing}_${tm}_${date}_ii${mult}_${lan}_largemult${largemult} &
    # sleep 30
    # time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${C} ${S} 3 ls_flowsize_80_64_1 | grep "FCT" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${lan}_largemult${largemult} &
    wait
}


run_cs_skewed
