for topo in {'rrg','ring'};
do
    echo "${topo}_data=\"\"\""
    for C in {20,60,100}; do S=$C; echo ""; for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); cat results_${topo}_SG${s}_${C}_${S} | grep "Avg throughput 2" | awk '{printf "%f ",$7}'; done; done; echo "";
    for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); C=$((svrs/8)); S=$C;   cat results_${topo}_SG${s}_${C}_${S} | grep "Avg throughput 2" | awk '{printf "%f ",$7}'; done; echo "";
    for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); C=$((svrs/4)); S=$((svrs/8));   cat results_${topo}_SG${s}_${C}_${S} | grep "Avg throughput 2" | awk '{printf "%f ",$7}'; done; echo "";
    for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); cat results_${topo}_SG${s}_random_20 | grep "Avg throughput 2"| awk '{printf "%f ",$7}';  done; echo "";
    echo "\"\"\""
done



for topo in {'rrg','ring'};
do
    echo "${topo}_data_10ile=\"\"\""
    for C in {20,60,100}; do S=$C; echo ""; for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); cat results_${topo}_SG${s}_${C}_${S} | grep "10ile" | awk '{printf "%f ",$6}'; done; done; echo "";
    for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); C=$((svrs/8)); S=$C;   cat results_${topo}_SG${s}_${C}_${S} | grep "10ile" | awk '{printf "%f ",$6}'; done; echo "";
    for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); C=$((svrs/4)); S=$((svrs/8));   cat results_${topo}_SG${s}_${C}_${S} | grep "10ile" | awk '{printf "%f ",$6}'; done; echo "";
    for s in {4..12..2}; do sw=$((s*6)); svrs=$((sw*20)); cat results_${topo}_SG${s}_random_20 | grep "10ile"| awk '{printf "%f ",$6}';  done; echo "";
    echo "\"\"\""
done
