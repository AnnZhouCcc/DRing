#!/bin/awk -f
{
    first_word = $1
    if (first_word == "topology") {
        sum_lower = 0
        sum_upper = 0
        path_len = 2
    }
    else {
        size = $2
        duration = $3
        start = $4
        end = start+duration
        if (start >= mstart && end < mend) {
            sum_lower += path_len*size
        }
        if ((start >= mstart && start < mend) || (end >= mstart && end < mend)) {
            sum_upper += path_len*size
        }
    }
}
END { 
    time = mend-mstart
    capacity_per_time = 2748776448
    total_capacity = time*capacity_per_time
    util_lower = sum_lower/total_capacity
    util_upper = sum_upper/total_capacity
    print filename," from",mstart,"to",mend," ",total_capacity," ",sum_lower," ",sum_upper," ",util_lower," ",util_upper
}
