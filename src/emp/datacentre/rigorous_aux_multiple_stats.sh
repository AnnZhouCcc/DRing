fileprefix=$1
seedfrom=$2
seedto=$3
mstart=$4
mend=$5

for seed in $(seq ${seedfrom} ${seedto})
do

  file=${fileprefix}${seed}
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
