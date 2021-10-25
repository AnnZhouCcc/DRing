routing=ecmp
k=0
rstag=ecmp
date=1024v3
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
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/unequal/modelVars_${rstag}_${tm}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 5
    wait
}


run_fbu(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="fbu"
    dp=2
    name="resilient"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_uniform.data"
    for mult in 1 2 6; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
}


run_fbs(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="fbs"
    dp=2
    name="unequal"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_skewed.data"
    for mult in 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    name="resilient"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_skewed.data"
    for mult in 4 5; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
}


run_mix5(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="mix5"
    dp=2
    name="unequal"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 5 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for mult in 5 6 7 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 5 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    name="resilient"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 5 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for mult in 5 6 7 8; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 5 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
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
    name="unequal"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for mult in 5 6 7; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for mult in 8 9 10; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    name="resilient"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for mult in 1 2 3 4; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for mult in 5 6 7; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for mult in 8 9 10; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} FLUID_MIX ${mult} ${numerator} ${denominator} ${routing} ${k} 10 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
}


run_a2a(){
    numerator=0
    denominator=0
    MAKE=NOMAKE
    tm="a2a"
    dp=2
    name="unequal"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_${rstag}_${tm}_${dp}dp.txt"
    for sr in 352 384; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for sr in 416; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    name="resilient"
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/${name}/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    for sr in 192 208 256; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for sr in 288 320; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for sr in 352 384; do
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
    for sr in 416; do
    tm=a2a_${sr}
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RANDOM ${sr} ${numerator} ${denominator} ${routing} ${k} ${sr} 0 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${sr}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
}


run_make
run_fbu
run_fbs
run_mix5
run_mix10
run_a2a
