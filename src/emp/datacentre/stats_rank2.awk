#!/bin/awk -f
{
    first_word = $1
    if (first_word == "topology") {
        
    }
    else {
        fct = $3
        start = $4
        if (start >= mstart && start < mend && fct >= n95) {
            print start
        }
    }
}
