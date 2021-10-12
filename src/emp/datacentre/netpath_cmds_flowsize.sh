routing=ecmp
k=0
date=1012
run_leafspine=false


run_a2a(){
    numerator=0
    denominator=0
    tm="a2a"
    MAKE=MAKE 
    sr=8
    tm=a2a_${sr}
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 dring_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    # sleep 5
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 5
    if [ "$run_leafspine" = true ]; then
        time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
        sleep 5
    fi
    wait
}


run_a2a
