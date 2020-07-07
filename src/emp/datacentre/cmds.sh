routing=s2
#for s in {8..10..2}
#for s in {12..16..2}
for s in {16..16}
do
    tm="a2a"
    sw=$((s*6))
    svrs=$((sw*36))
    sr_fp=$((904/s)) #corresponding to 10%avg . util with 50ms simtime
    printf -v int %.0f "${sr_fp}"
    sr=${sr_fp}
    echo "${sr_fp} ${sr}"
    tm=${tm}_${sr}
    MAKE=MAKE
    time ./run.sh RRG 1 60 0 graphfiles/ring_supergraph/new/instance1_${sw}_60.edgelist ${svrs} 1 1 ${MAKE} RANDOM ${sr} 0 3 dring_${routing}_${sw}_60_1 | grep "FCT" > fct_results/scale/dring_${s}_${routing}_${tm} &
    sleep 30
    time ./run.sh RRG 1 60 0 graphfiles/ring_supergraph/new/rrg/snodes${s}/instance1_${sw}_60.edgelist ${svrs} 1 1 ${MAKE} RANDOM ${sr} 0 3 rrg_${routing}_${sw}_60_1 | grep "FCT" > fct_results/scale/rrg_${s}_${routing}_${tm} &
    sleep 30
done

wait
