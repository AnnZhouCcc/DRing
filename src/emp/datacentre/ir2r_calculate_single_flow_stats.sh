dir=/home/annzhou/DRing/src/emp/datacentre/compressed_discover_logfiles/discover_rrg_ecmp_r2r1_lppbr/discover_dring_su3_r2r0_equal/
fileprefix=48_125_1000_1000_
seedfrom=400
seedto=499
mstart=250
mend=750

combinedfile=${dir}${fileprefix}${seedfrom}_${seedto}_combined
for seed in $( seq $seedfrom $seedto )
do
  thisfile=${dir}${fileprefix}${seed}
  cat $thisfile | grep -e "FCT" >> $combinedfile
done
./discover_aux_single_stats.sh $combinedfile $mstart $mend

rm $combinedfile
