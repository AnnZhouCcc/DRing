#!/bin/awk -f
{ 
    if (NR == 1) {
        first_word = $1
        offset = first_word == "topology" ? 1 : 3
    }
    if (NR > offset) {
	numbers[NR-offset] = $3
    }
}
END { 
    asort(numbers)
    num_line = NR-offset;
    n99p99_index = int(num_line*0.9999);
    n99p99 = numbers[n99p99_index]
    print filename," ",n99p99;
}
