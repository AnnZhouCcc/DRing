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
    if (num_line%2==0) {
	    lower = numbers[int(num_line/2)]
        upper = numbers[int(num_line/2)+1]
        median = (lower+upper)/2
    } else {
	    median = numbers[int(num_line/2)]
    }	
    print filename," from",mstart,"to",mend," ",median;
}
