outputfileprefix=$1
seedfrom=$2
seedto=$3
mstart=$4
mend=$5
statssummaryfile=$6

if [ ! -s $statssummaryfile ]
then
  ./rigorous_aux_multiple_stats.sh $outputfileprefix $seedfrom $seedto $mstart $mend > $statssummaryfile
fi

linecount=0
n99fctsum=0
totaltrafficsum=0
let numruns=$seedto-$seedfrom+1
while IFS= read -r line
do
  let oddoreven=$linecount%2
  if [ $oddoreven -eq 0 ]
  then
    # fct stats
    n99fct=$(echo $line | cut -d " " -f 7)
    #let n99fctsum=$n99fctsum+$n99fct
    n99fctsum=$(echo $n99fctsum + $n99fct | bc)
  else
    # flow size stats
    totaltraffic=$(echo $line | cut -d " " -f 6)
    let totaltrafficsum=$totaltrafficsum+$totaltraffic
  fi
  ((linecount++))
done < $statssummaryfile

divide() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1/n2)}'
}

#n99fctaverage=$(echo "scale=8 ; $n99fctsum / $numruns" | bc)
#totaltrafficaverage=$(echo "scale=2 ; $totaltrafficsum / $numruns" | bc)
n99fctaverage=$(divide $n99fctsum $numruns)
totaltrafficaverage=$(divide $totaltrafficsum $numruns)

echo $n99fctaverage $totaltrafficaverage
