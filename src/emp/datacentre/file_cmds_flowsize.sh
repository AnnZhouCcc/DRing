routing=su
k=3
date=916v2
name=a
run_leafspine=false


run_fb_tms(){
    numerator=0
    denominator=0
    tm="mix_4"
    # for mult in 2 4 6 8 10 12 14; do
    mult=16
    tmfile="mix_4_tm_raw_dring.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name} &
    sleep 5
    tmfile="mix_4_tm_raw_rrg.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name} &
    if [ "$run_leafspine" = true ]; then
        sleep 5
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name} &
    fi
    sleep 5
    # done
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
    inst=50 # need to change manually in code
    mult=0
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 30
    if [ "$run_leafspine" = true ]; then
        sleep 30
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    fi
    sleep 30
    # done
    wait
}

run_r2r_tms
run_fb_tms
