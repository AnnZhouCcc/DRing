routing=kshort
k=32
rstag=32short
date=1104v2


run_make(){
    numerator=1
    denominator=10
    tm="r2r"
    C=48
    S=48
    MAKE=MAKE
    inst=1
    mult=0

    topology=rrg
    npfile="none"
    name=make
    dp=0
    pwfile="none"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30

    # topology=dring
    # npfile="none"
    # name=make
    # dp=0
    # pwfile="none"
    # time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    # sleep 30
    wait
}


run_mix10(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="mix10"

    topology=rrg
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"

    name=unequal
    dp=2
    pwfile="pathweightfiles/${topology}/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    for mult in 9 10 11 12; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait

    name=resilient
    dp=2
    pwfile="pathweightfiles/${topology}/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for mult in 9 10 11 12; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
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

    topology=rrg
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"

    name=unequal
    dp=2
    pwfile="pathweightfiles/${topology}/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    for mult in 4 8 12; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 16 20 24; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 28 32 36; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait

    name=resilient
    dp=4
    pwfile="pathweightfiles/${topology}/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for mult in 4 8 12; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 16 20 24; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 28 32 36; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
}


run_16to4(){
    numerator=0
    denominator=0
    tm="16to4"
    C=768
    S=192
    MAKE=NOMAKE

    topology=rrg
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"

    name=unequal
    dp=2
    pwfile="pathweightfiles/${topology}/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 5 6 7 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait

    name=resilient
    dp=3
    pwfile="pathweightfiles/${topology}/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 5 6 7 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
}


run_4to16(){
    numerator=0
    denominator=0
    tm="4to16"
    C=192
    S=768
    MAKE=NOMAKE

    topology=rrg
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"

    name=unequal
    dp=2
    pwfile="pathweightfiles/${topology}/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 5 6 7 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait

    name=resilient
    dp=3
    pwfile="pathweightfiles/${topology}/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 5 6 7 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FEW_TO_SOME ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
}


run_fbs(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="fbs"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_skewed.data"

    topology=dring
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"

    name=unequal
    dp=2
    pwfile="pathweightfiles/${topology}/${name}/modelVars_dring_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait

    name=resilient
    dp=3
    pwfile="pathweightfiles/${topology}/${name}/modelVars_lp2_dring_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
}


run_fbu(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="fbu"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_uniform.data"

    topology=dring
    npfile="netpathfiles/netpath_${rstag}_${topology}.txt"

    name=unequal
    dp=2
    pwfile="pathweightfiles/${topology}/${name}/modelVars_dring_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    for mult in 5 6 7; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait

    name=resilient
    dp=3
    pwfile="pathweightfiles/${topology}/${name}/modelVars_lp2_dring_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
    for mult in 5 6 7; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist 2988 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 dring_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/dring_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 30
    done
    wait
}


run_make
run_mix10
# run_r2r
# run_16to4
# run_4to16
# run_fbs
# run_fbu
