routing=ecmp
k=0
rstag=ecmp
date=0507t100a2alsreport


run_make(){
    numerator=1
    denominator=10
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    mult=0
    npfile="none"
    solve_starttime=0
    solve_endtime=0
    name=make
    dp=0
    pwfile="none"
    mstart=0
    mend=1
    stime=60
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${solve_starttime}_${solve_endtime}_${dp}dp_${name}_${mstart}_${mend}_${stime} &
    wait
}


run_4to16(){
    MAKE=NOMAKE
    tm="4to16"
    C=768
    S=192
    npfile="none"
    dp=0
    pwfile="none"
    solve_starttime=0
    solve_endtime=0
    stime=500
    mstart=0
    mend=501

    denominator=0
    numerator=0
    for mult in 1 2 3 4; do
    name=run1
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait
}


run_r2r(){
    tm="r2r"
    C=48
    S=48
    MAKE=NOMAKE
    npfile="none"
    solve_starttime=0
    solve_endtime=0
    dp=0
    pwfile="none"
    mstart=0
    mend=2001
    stime=2000
    numerator=0
    denominator=0

    for mult in 525; do
    name=run1
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run2
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run3
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run4
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    name=run5
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${C} ${S} 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    done
    wait
}


run_a2a(){
    MAKE=NOMAKE
    npfile="none"
    dp=0
    pwfile="none"
    solve_starttime=0
    solve_endtime=0
    stime=100
    mstart=0
    mend=101

    numerator=0
    denominator=0
    for sr in 50 100 200 300 400 500 600; do
    tm=a2a_${sr}
    name=run1
    time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    sleep 5
    # name=run2
    # time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    # sleep 5
    # name=run3
    # time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    # sleep 5
    # name=run4
    # time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    # sleep 5
    # name=run5
    # time ./run.sh LEAFSPINE 1 64 16 null 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${solve_starttime} ${solve_endtime} ${routing} ${k} ${sr} 0 3 ls_flowsize_80_64_1 ${npfile} ${pwfile} ${dp} ${mstart} ${mend} ${stime} | grep -e "FCT" -e "topology" > fct_results_${date}/ls_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${name}_${mstart}_${mend}_${stime} &
    # sleep 5
    done
    wait
}


run_make
# run_4to16
# run_r2r
run_a2a
