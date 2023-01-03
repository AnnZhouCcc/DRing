#!/bin/bash

#convert input number to mult+numerator/denominator
mult=$(echo $1 | cut -d . -f 1)
frac=$(echo $1 | cut -d . -f 2)
let numzero=$(echo $frac | wc -m)-1
let denominator=10**$numzero
let numerator=$frac
echo $mult $numerator $denominator
