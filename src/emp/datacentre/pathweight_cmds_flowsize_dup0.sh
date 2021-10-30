routing=ecmp
k=0
rstag=ecmp
date=1030


run_make(){
    numerator=1
    denominator=10
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    inst=1
    mult=0
    dp=2
    name=
    npfile="none"
    pwfile="none"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    wait
}


run_r2r(){
    numerator=0
    denominator=0
    tm="r2r"
    C=48
    S=48
    MAKE=NOMAKE
    inst=1
    dp=2
    name=equal
    npfile="none"
    pwfile="none"
    for mult in 10 20 30 40; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 10 20 30 40; do
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
}


run_make
run_r2r
