#!/bin/awk -f
{ 
    if (NR == 1) {
        total_path_lengths = $2
        total_available_paths = $3
        total_available_first_hops = $4
    }
}
END { 
    num = NR-1;
    avg_path_lengths = total_path_lengths/num;
    avg_available_paths = total_available_paths/num;
    avg_available_first_hops = total_available_first_hops/num;
    print filename," ",total_path_lengths," ",avg_path_lengths," ",total_available_paths," ",avg_available_paths," ",total_available_first_hops," ",avg_available_first_hops;
}
