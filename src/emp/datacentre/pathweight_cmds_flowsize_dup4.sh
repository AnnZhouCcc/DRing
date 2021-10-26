routing=su
k=2
rstag=su2
date=1026v8
run_leafspine=false


run_make(){
    numerator=1
    denominator=10
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    inst=50
    mult=0
    dp=2
    npfile="none"
    pwfile="none"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 5
    wait
}


run_a2a(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="a2a"
    dp=2
    name="resilient"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for sr in 224 256; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for sr in 288 320; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
}


run_make
run_a2a
