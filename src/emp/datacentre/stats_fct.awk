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
            numbers[num_line] = $3
            sizes[num_line] = $2
            num_line += 1
        }
    }
}
END { 
    average = num_line>0 ? sum/num_line : 0
    asort(numbers)
    asort(sizes)
    if (num_line%2==0) {
	    lower = numbers[int(num_line/2)]
        upper = numbers[int(num_line/2)+1]
        median = (lower+upper)/2

        lower_size = sizes[int(num_line/2)]
        upper_size = sizes[int(num_line/2)+1]
        median_size = (lower_size+upper_size)/2
    } else {
	    median = numbers[int(num_line/2)]
        median_size = sizes[int(num_line/2)]
    }
    n99_index = int(num_line*0.99)
    n99 = numbers[n99_index]
    n99_size = sizes[n99_index]
    max = numbers[num_line]
    max_size = sizes[num_line]
    print filename," from",mstart,"to",mend," ",average," ",median," ",median_size," ",n99," ",n99_size," ",max," ",max_size
}
