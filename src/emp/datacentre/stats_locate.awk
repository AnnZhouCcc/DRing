#!/bin/awk -f
{
    first_word = $1
    if (first_word == "topology") {
        found = 0
    }
    else {
        start = $4
        if (start >= mstart && start < mend) {
            if ($3 == targetfct) {
                found = 1
                print "flow with FCT ",$3," has size ",$2," and packets sent ",$5," that starts at time ",$4
            }
        }
    }
}
END { 
    if (found == 0) {
        print "not found"
    }
    else {
        print "found"
    }
}
