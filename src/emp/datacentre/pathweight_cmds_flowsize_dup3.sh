routing=ecmp
k=0
rstag=ecmp
date=1027


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
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    wait
}


run_mix5(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="mix5"
    dp=2
    name="ls_ecmp_equal"
    npfile="none"
    pwfile="none"
    for mult in 1 2 3 4; do
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 5 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for mult in 5 6 7 8; do
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 5 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
}


run_mix10(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="mix10"
    dp=2
    name="ls_ecmp_equal"
    npfile="none"
    pwfile="none"
    for mult in 1 2 3 4; do
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
}


run_make
run_mix5
run_mix10
