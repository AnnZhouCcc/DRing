#!/bin/awk -f
{ 
    first_word = $1
    if (first_word == "topology") {
        sum = 0
        actual = 0
        num_line = 0
    }
    else {
        start = $4
        if (start >= mstart && start < mend) {
            sum += $2
	        actual = $6
            num_line += 1
        }
    }
}
END { 
    average = num_line>0 ? sum/num_line : 0
    actual_average = num_line>0 ? actual/num_line : 0
    retrans = average>0 ? (actual_average-average)/average : 0
    print filename," from",mstart,"to",mend," ",num_line," ",sum," ",average," ",actual," ",actual_average," ",retrans;
}
