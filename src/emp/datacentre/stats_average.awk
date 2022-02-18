#!/bin/awk -f
{
    first_word = $1
    if (first_word == "topology") {
        sum = 0
        num_line = 0
    }
    else {
        start = $4
        if (start >= mstart && start < mend) {
            sum += $3
            num_line += 1
        }
    }
}
END { 
    average = num_line>0 ? sum/num_line : 0;
    print filename," from",mstart,"to",mend," ",average;
}
