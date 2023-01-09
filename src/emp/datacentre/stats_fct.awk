#!/bin/awk -f
BEGIN {
    sum = 0
    num_line = 0
    max = 0
}
{
    first_word = $1
    if (first_word == "FCT") {
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
    n95_index = int(num_line*0.95)
    n95 = numbers[n95_index]
    tail_num = n99_index-n95_index+1
    tail_sum = 0
    for(i=n95_index; i<=n99_index; i++)
        tail_sum += numbers[i]
    tail_average = tail_sum/tail_num
    print filename,mstart,mend,average,median,n95,n99,max,tail_average
}
