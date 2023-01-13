topology=$1
routing=$2
traffic=a2a
tag=${topology}_${routing}_${traffic}
command="tar -czvf comprover_${tag}.tar.gz"
suffices='equal weighted lppbr lpdbr'
for suffix in $suffices
do
  dir=discover_${tag}_${suffix}
  if [ -d $dir ]
  then
    command=$(echo ${command}" "${dir}/)
  fi
done
$($command)
