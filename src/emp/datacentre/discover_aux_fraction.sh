#!/bin/bash

#convert input number to mult+numerator/denominator
num=$1
if [[ $num == *"."* ]]
then
  mult=$(echo $num | cut -d . -f 1)
  frac=$(echo $num | cut -d . -f 2)
  let numzero=$(echo $frac | wc -m)-1
  let denominator=10**$numzero
  frac=$( expr $frac + 0 )
  let numerator=$frac
  echo $mult $numerator $denominator
else
  echo $num 0 0
fi
