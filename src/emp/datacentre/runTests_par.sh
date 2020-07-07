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
PARAM=$9
PARAMO=${10}
SEED=${11}
SUFFIX=${12}


NINST=3
PARAM2=`echo ${PARAM}| sed -e 's/\//$/g'`
tempResultFile=tempresult_$1_$2_$3_$4_$5_$6_$7_$8_${PARAM2}_${PARAMO}_${SEED}_${12}
echo $tempResultFile
rm -rf $tempResultFile

runsim() {
	INST=$1
	inputfile=graphfiles/ring_supergraph/instance1_${NSW}_${NPORTS}.edgelist
	#inputfile=graphfiles/flat_leaf_spine/instance${INST}_${NSW}_${NPORTS}.edgelist
	#inputfile=graphfiles/kell4ips${INST}_${NSW}_${NPORTS}.edgelist
	make="NOMAKE"
	if [[ $1 == "1" && $MAKE == "MAKE" ]]; then
	    make="MAKE"
	fi
	if [[ $TMatrix == "FILE" ]]; then
        #    OINST=`python -c "print 1 + (${OFFSET} + ${INST} - 1)%${NINST}"`
	    PARAM="${PARAM}_${INST}"
	    echo $PARAM
	fi
	echo "${INST}) make: $make"
	resultfile=temppp_${SUFFIX}_${INST}
    rm -rf $resultfile
    ./run.sh RRG ${SUBFLOWS} ${NPORTS} ${PATHS} $inputfile ${NSVRS} 1 ${OVERSUBSCRIPTION} $make $TMatrix $PARAM ${PARAMO} ${SEED} ${SUFFIX} >> $resultfile
    tput=`cat $resultfile | grep "avg_throughput" | awk '{print $2}'`
    tput_10ile=`cat $resultfile | grep "10ile_throughput" | awk '{print $2}'`
    link_usage=`cat $resultfile | grep "avg_link_usage" | awk '{print $2}'`
	rm -rf $resultfile
    echo "${INST}) $tput $tput_10ile"
	echo "$tput $link_usage $tput_10ile" >> $tempResultFile 
	count=`cat $tempResultFile | wc -l`	
	echo "count: $count"
	if [[ $count == "$NINST" ]]; then
	    avg_tput=`cat $tempResultFile | awk '{if(NF>0){sum+=$1; cnt++;}} END{print sum/cnt}'`
	    avg_link_usage=`cat $tempResultFile | awk '{if(NF>0){sum+=$2; cnt++;}} END{print sum/cnt}'`
	    avg_tput_10ile=`cat $tempResultFile | awk '{if(NF>0){sum+=$3; cnt++;}} END{print sum/cnt}'`
	    rm -rf $tempResultFile
 	    echo "Avg throughput ( $SUFFIX ): $avg_tput"
	    avg_tput2=`python -c "print ${avg_tput} * ${OVERSUBSCRIPTION}"` 
 	    echo "Avg throughput 2 ( $SUFFIX ): $avg_tput2"
 	    echo "10ile throughput ( $SUFFIX ): $avg_tput_10ile"
 	    echo "Avg Link Usage ( $SUFFIX ): $avg_link_usage"
 	    #echo "Avg throughput: $avg_tput" >> $tempResultFile
	fi
}

<<COMMENT1
for INST in `seq 1 ${NINST}`;
do
	echo $NSW
	echo $NPORTS
	inputfile=graphfiles/instance${INST}_${NSW}_${NPORTS}.edgelist
	#inputfile=graphfiles/kell4ips${INST}_${NSW}_${NPORTS}.edgelist
	#cp ../../../../jellyfishRouting/Networks/deg${NPORTS}_sw${NSW}_svr${NSVRS}_i${INST}.edgelist $inputfile
	#sed -i 's/ /->/g' $inputfile
done
COMMENT1

for INST in `seq 1 ${NINST}`;
do
	#inputfile=graphfiles/instance${INST}_${NSW}_${NPORTS}.edgelist
	#inputfile=graphfiles/kell4ips${INST}_${NSW}_${NPORTS}.edgelist
	runsim $INST &
	pids[${INST}]=$!
	if [[ $INST == "1" && $MAKE == "MAKE" ]]; then
	    sleep 30 #wait for makefile to finish, hacky but whatever
	fi
	sleep 1.5
done

for pid in ${pids[@]};
do 
	wait $pid; 
done

