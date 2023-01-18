fileprefix=$1
rigorousseedfrom=$2
rigorousseedto=$3
discoverseedfrom=$4
discoverseedto=$5
mstart=$6
mend=$7

calculateSeedFrom() {
  awk -v rigorousseed="$1" -v discoverseedfrom="$2" -v discoverseedto="$3" 'BEGIN {printf (rigorousseed*(discoverseedto-discoverseedfrom+1))}'
}

calculateSeedTo() {
  awk -v rigorousseed="$1" -v discoverseedfrom="$2" -v discoverseedto="$3" 'BEGIN {printf ((rigorousseed+1)*(discoverseedto-discoverseedfrom+1)-1)}'
}

for rigorousseed in $(seq $rigorousseedfrom $rigorousseedto)
do
  seedfrom=$(calculateSeedFrom $rigorousseed $discoverseedfrom $discoverseedto)
  seedto=$(calculateSeedTo $rigorousseed $discoverseedfrom $discoverseedto)
  file=${fileprefix}_${seedfrom}_${seedto}
  filename=${file##*/}

  #echo -e "\nAVERAGE | MEDIAN | N95 | N99 | MAX | TAIL AVERAGE"
  if [ -e $file ]
  then
    cat $file | awk -v filename=$filename -v mstart=$mstart -v mend=$mend -f stats_fct.awk
  fi

  #echo -e "\nDURATION | #FLOWS | TOTAL FLOW SIZE | AVERAGE FLOW SIZE | #FLOW STARTS/TIME | TOTAL FLOW SIZE/TIME | FLOWxDURATION/TIME"
  if [ -e $file ]; then
    cat $file | awk -v filename=$filename -v mstart=$mstart -v mend=$mend -f stats_flow_size.awk
  fi
done
