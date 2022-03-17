#!/bin/awk -f
{
    first_word = $1
    if (first_word == "topology") {
        num_line = 0
        should_print = 0
    }
    else {
        if (should_print == 1) {
            print
            should_print = 0
        }
        else {
            fct = $3
            start = $4
            if (start >= mstart && start < mend && fct >= n95) {
                should_print = 1
            }
        } 
    }
}
