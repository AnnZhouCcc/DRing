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
    if (num_line%2==0) {
	lower = numbers[int(num_line/2)]
        upper = numbers[int(num_line/2)+1]
        median = (lower+upper)/2
    } else {
	median = numbers[int(num_line/2)]
    }	
    print filename," ",median;
}
