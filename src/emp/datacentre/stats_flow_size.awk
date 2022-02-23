#!/bin/awk -f
{ 
    first_word = $1
    if (first_word == "topology") {
        sum = 0
        num_line = 0
        sum_duration = 0
    }
    else {
        start = $4
        if (start >= mstart && start < mend) {
            sum += $2
            num_line += 1
            sum_duration += $2*$3
        }
    }
}
END { 
    average = num_line>0 ? sum/num_line : 0
    total_duration = mend-mestart
    traffic_per_time = sum/total_duration
    flow_start_per_time = num_line/total_duration
    traffic_duration_per_time = sum_duration/total_duration
    print filename," from",mstart,"to",mend," ",num_line," ",sum," ",average;
    print filename," flow start per time=",flow_start_per_time,", traffic per time=",traffic_per_time,", traffic x duration per time=",traffic_duration_per_time;
}
