#!/bin/bash


##Use it to run only with one traffic matrix
NSW=$1
NPORTS=$2
NSVRS=$3
SUBFLOWS=$4
PATHS=$5
OVERSUBSCRIPTION=$6
TMatrix=$7
MAKE=$8
GRAPHFILE=$9
PARAM=${10}
SUFFIX=${11}
OFFSET=${12}


NINST=5
PARAM2=`echo ${PARAM}| sed -e 's/\//$/g'`
GRAPHFILE2=`echo ${GRAPHFILE}| sed -e 's/\//$/g'`
tempResultFile=tempresult_$1_$2_$3_$4_$5_$6_$7_$8_${GRAPHFILE2}_${PARAM2}_${11}
rm -rf $tempResultFile

runsim() {
	INST=$1
	inputfile=${GRAPHFILE}
	make="NOMAKE"
	if [[ $1 == "1" ]]; then
	    make="MAKE"
	fi
	if [[ $TMatrix == "FILE" ]]; then
            OINST=`python -c "print 1 + (${OFFSET} + ${INST} - 1)%${NINST}"`
	    PARAM="${PARAM}_${OINST}"
	    echo $PARAM
	fi
	echo "${INST}) make: $make"
	resultfile=temppp_${SUFFIX}_${INST}
    rm -rf $resultfile
    ./run.sh RRG ${SUBFLOWS} ${NPORTS} ${PATHS} $inputfile ${NSVRS} 1 ${OVERSUBSCRIPTION} $make $TMatrix $PARAM ${SUFFIX} >> $resultfile
    tput=`cat $resultfile | grep "avg_throughput" | awk '{print $2}'`
    link_usage=`cat $resultfile | grep "avg_link_usage" | awk '{print $2}'`
	rm -rf $resultfile
	echo "${INST}) $tput"
	echo "$tput $link_usage" >> $tempResultFile 
	count=`cat $tempResultFile | wc -l`	
	echo "count: $count"
	if [[ $count == "$NINST" ]]; then
	    avg_tput=`cat $tempResultFile | awk '{if(NF>0){sum+=$1; cnt++;}} END{print sum/cnt}'`
	    avg_link_usage=`cat $tempResultFile | awk '{if(NF>0){sum+=$2; cnt++;}} END{print sum/cnt}'`
	    rm -rf $tempResultFile
 	    echo "Avg throughput ( $SUFFIX ): $avg_tput"
	    avg_tput2=`python -c "print ${avg_tput} * ${OVERSUBSCRIPTION}"` 
 	    echo "Avg throughput 2 ( $SUFFIX ): $avg_tput2"
 	    echo "Avg Link Usage ( $SUFFIX ): $avg_link_usage"
 	    #echo "Avg throughput: $avg_tput" >> $tempResultFile
	fi
}


for INST in `seq 1 ${NINST}`;
do
	echo $NSW
	echo $NPORTS
	inputfile=${GRAPHFILE}
	sed -i 's/ /->/g' $inputfile
done



for INST in `seq 1 ${NINST}`;
do
	inputfile=${GRAPHFILE}
	runsim $INST &
	pids[${INST}]=$!
	if [[ $INST == "1" ]]; then
	    sleep 20 #wait for makefile to finish, hacky but whatever
	fi
	sleep 10
done

for pid in ${pids[@]};
do 
	wait $pid; 
done

