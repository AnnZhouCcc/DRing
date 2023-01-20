#!/bin/bash
topology=rrg
routings='ecmp su2 32disjoint 32short racke0 racke1 racke2'
traffics='a2a r2r0 r2r1 clusterb'
for routing in $routings
do
  for traffic in $traffics
  do
    dir=/home/annzhou/DRing/src/emp/datacentre/pathweightfiles/${topology}/${routing}/${traffic}/
    for filename in ${dir}*.txt; do
      mv $filename ${dir}legacy_$(basename $filename)
    done
  done
done
