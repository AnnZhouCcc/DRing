#dir=/home/annzhou/DRing/src/emp/datacentre/compressed_discover_logfiles/discover_rrg_ecmp_r2r1_lppbr/discover_dring_su3_r2r0_equal/
dir=/users/ruipan/DRing/src/emp/datacentre/ir2r_jan31-randomize-server-r2r-0/
fileprefix=leafspine_ecmp_equal_300_0_0_1000_
seedfrom=0
seedto=49
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
