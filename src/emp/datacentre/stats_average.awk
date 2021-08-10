#!/bin/awk -f
{ 
    if (NR == 1) {
        first_word = $1
        offset = first_word == "topology" ? 1 : 3
    }
    if (NR > offset) {
	sum += $3
    }
}
END { 
    num_line = NR-offset;
    average = num_line>0 ? sum/num_line : 0;
    print filename," ",average;
}
