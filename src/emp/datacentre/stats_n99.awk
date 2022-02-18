#!/bin/awk -f
{ 
    first_word = $1
    if (first_word == "topology") {
        num_line = 0
    }
    else {
        start = $4
        if (start >= mstart && start < mend) {
            numbers[num_line] = $3
            num_line += 1
        }
    }
}
END { 
    asort(numbers)
    n99_index = int(num_line*0.99);
    n99 = numbers[n99_index]
    print filename," from",mstart,"to",mend," ",n99;
}
