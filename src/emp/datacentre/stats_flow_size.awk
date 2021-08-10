#!/bin/awk -f
{ 
    if (NR == 1) {
        first_word = $1
        offset = first_word == "topology" ? 1 : 3
    }
    if (NR > offset) {
	sum += $2
	actual = $6
    }
}
END { 
    num_line = NR-offset;
    average = num_line>0 ? sum/num_line : 0
    actual_average = num_line>0 ? actual/num_line : 0
    retrans = average>0 ? (actual_average-average)/average : 0
    print filename," ",num_line," ",sum," ",average," ",actual," ",actual_average," ",retrans;
}
