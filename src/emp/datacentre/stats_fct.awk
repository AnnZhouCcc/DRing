#!/bin/awk -f
{
    first_word = $1
    if (first_word == "topology") {
        sum = 0
        num_line = 0
        max = 0
    }
    else {
        start = $4
        if (start >= mstart && start < mend) {
            sum += $3
            numbers[num_line] = $3
            if ($3 > max) {
                max = $3
            }
            num_line += 1
        }
    }
}
END { 
    average = num_line>0 ? sum/num_line : 0
    asort(numbers)
    if (num_line%2==0) {
	    lower = numbers[int(num_line/2)]
        upper = numbers[int(num_line/2)+1]
        median = (lower+upper)/2
    } else {
	    median = numbers[int(num_line/2)]
    }
    n99_index = int(num_line*0.99)
    n99 = numbers[n99_index]
    print filename," from",mstart,"to",mend," ",average," ",median," ",n99," ",max
}
