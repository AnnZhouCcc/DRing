#!/bin/bash

#for r in "05" "10" "15" "20" "25" "30" "35" "40"
for r in "00"
do
	for run in 1 2 3 4 5
	do
		#echo ./run.sh FAT 8 6 8 file 0."$r"
		./runfattree.sh FAT 8 6 8 file 0."$r" $run
	done
done
