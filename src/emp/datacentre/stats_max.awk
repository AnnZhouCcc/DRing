#!/bin/awk -f
{ 
    first_word = $1
    if (first_word == "topology") {
        num_line = 0
        max = 0
    }
    else {
        start = $4
        if (start >= mstart && start < mend) {
            if ($3 > max) {
                max = $3
            }
            num_line += 1
        }
    }
}
END {
    print filename," from",mstart,"to",mend," ",max;
}
