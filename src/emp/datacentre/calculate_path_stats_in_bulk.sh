traffic=$1
topologies='rrg dring'
routings='ecmp su2 su3 32disjoint 32short racke0 racke1 racke2'

echo $traffic
for topology in $topologies
do
    for routing in $routings
    do
        echo $topology $routing pbr
        #python3 calculate_path_stats_for_synthetic_traffic.py $topology $routing $traffic 0
        python3 calculate_path_stats_for_cluster_traffic.py $topology $routing $traffic 0
        if [ $routing = "ecmp" ] || [ $routing = "su2" ] || [ $routing = "su3" ]
        then
            echo $topology $routing dbr
            #python3 calculate_path_stats_for_synthetic_traffic.py $topology $routing $traffic 1
            python3 calculate_path_stats_for_cluster_traffic.py $topology $routing $traffic 1
        fi
    done
done      
