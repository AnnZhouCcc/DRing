routing=ecmp
k=0
rstag=ecmp
date=1024v2
name=resilient
run_leafspine=false


run_fb_tms(){
    numerator=0
    denominator=0
    tm="fbs"
    for dp in 1 2 3 4; do
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/resilient/modelVars_lp2_${rstag}_${tm}_${dp}dp.txt"
    tmfile="graphfiles/ring_supergraph/ls_x48_y16_skewed.data"
    mult=3
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 NOMAKE FILE ${mult} ${numerator} ${denominator} ${routing} ${k} ${tmfile} 10 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator}_${dp}dp_${name} &
    sleep 5
    done
    wait
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
    dp=2
    npfile="netpathfiles/netpath_${rstag}_rrg.txt"
    pwfile="pathweightfiles/unequal/modelVars_${rstag}_${tm}_${dp}dp.txt"
    time ./run.sh RRG 1 64 16 graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist 3072 1 1 ${MAKE} RACK_TO_RACK ${mult} ${numerator} ${denominator} ${routing} ${k} ${C} ${S} 3 rrg_${routing}_80_64_1 ${npfile} ${pwfile} ${dp} | grep -e "FCT" -e "topology" > fct_results_${date}/rrg_${routing}_${k}_${tm}_${date}_ii${mult}_${numerator}_${denominator} &
    sleep 5
    wait
}

run_r2r_tms
run_fb_tms
