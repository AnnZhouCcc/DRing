outputfile=$1
mstart=$2
mend=$3
tempoutputfile=$4
tempoutputfile=${tempoutputfile}_output

./discover_aux_single_stats.sh $outputfile $mstart $mend > $tempoutputfile

fctstats=$(cat $tempoutputfile | cut -d " " -f 7)
count=0
for fctstat in $fctstats
do
  if [ $count -eq 0 ]
  then
    n99fct=$fctstat
  fi    
  let count++
done  

sizestats=$(cat $tempoutputfile | cut -d " " -f 6)
count=0
for sizestat in $sizestats
do
  if [ $count -eq 1 ]
  then
    totaltraffic=$sizestat
  fi  
  let count++
done  
echo $n99fct $totaltraffic

rm $tempoutputfile
