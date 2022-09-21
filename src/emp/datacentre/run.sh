#!/bin/bash
# USAGE: ./run.sh [topology type] [# subflows] [total # ports] [# paths] [topologyfile] [nservers] [nclusters] [oversubscription] [make? MAKE: NOMAKE] [TM_Matrix:PERM/SAMPLED_PERM/STRIDE/STGD_PERM/HOT_SPOT/MANY_TO_MANY/RANDOM/MAX_WT/RACK_TO_RACK/RACK_PERM/ALL_TO_ALL/FEW_TO_SOME/ALL_TO_FEW/FILE/UNIFORM] [multiplier] [param:optional] [paramo:optional] [seed:optional] [suffix: optional] 

#rm -rf main.o fattree leafspine rrg

PARTITION=FALSE
MULT=${11}
NUMERATOR=${12}
DENOMINATOR=${13}
SOLVESTART=${14}
SOLVEEND=${15}
ROUTING=${16}
KorN=${17}
PARAM=${18}
PARAMO=${19}
SEED=${20}
SUFFIX=${21}
NETPATH=${22}
PATHWEIGHT=${23}
DP=${24}
MSTART=${25}
MEND=${26}
STIME=${27}
SOLVEINTERVAL=${28}
COMPUTESTART=${29}
COMPUTEEND=${30}
COMPUTEINTERVAL=${31}

if [[ $1 == "FAT" ]]; then
    NHOST=`expr $3 \* $3 \* $3 / 4`
    NSW=`expr 5 \* $3 \* $3 / 4`
    OVERSUBSCRIPTION=$8
    NHOST=`expr $OVERSUBSCRIPTION \* $NHOST`
    if [[ $9 == "MAKE" ]]; then
        cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/0/g' | sed 's/P_SED/0/g' | sed 's/K_SED/'"$3"'/g' | sed 's/CHOSEN_TOPO_SED/'"$1"'/g' | sed 's/NUMPATHS_SED/0/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g' > main.h 
	make fattree
	mv fattree fattree_${SUFFIX}
    fi
    PARAM2=`echo ${PARAM}| sed -e 's/\//$/g'`
    tempResultFile=fat_output_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    tempLogFile=fat_pathlog_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    echo $tempResultFile
    ./fattree_${SUFFIX} -o ${tempLogFile} -sub $2 -TMatrix ${10} -mult ${MULT}  -param ${PARAM} -paramo ${PARAMO} | tee $tempResultFile
    #cat fat_output | grep Throughput | awk -F " " '{thr[$5]=$2} END{for(sid in thr) print thr[sid]}' | awk -v nhost="$NHOST" '{sum+=$1} END{print sum/nhost/61}'
    #echo $tempResultFile
    #cat $tempResultFile | grep "Throughput" | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); print arr[1] " " thr[sid];}}'  | sort -n -k1 | awk -v nhost="$NHOST" '{sum[$1]+=$2} END{for(s in sum) print s,sum[s]/nhost/61}' | sort -n 
    tput=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); print arr[1] " " thr[sid];}}'  | sort -n -k1 | awk -v nhost="$NHOST" '{sum[$1]+=$2} END{for(s in sum) print s,sum[s]/nhost/61}' | sort -n | awk ' END { print } ' | awk '{ sum += $2 } END { if (NR > 0) print sum / NR }'`
    tput2=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k1 | awk -v nhost="$NHOST" '{ sum += $2 } END { print sum/nhost }'`
    link_bw_usage=`cat $tempResultFile | grep "Link Usage" | awk '{print $6}'`
    link_bw_usage_file=fat_link_bw_usage_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    rm -rf ${link_bw_usage_file}
    echo "${link_bw_usage}" >> ${link_bw_usage_file}
    avg_link_usage=`awk '{ total += $1 } END { print (total/NR)/61 }' ${link_bw_usage_file}`
    tempFlowTputFile=fat_flowtput_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    tempFlowDistFile=fat_flowdist_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    #tputVsPathLenFile=fat_tput_vs_pathlen_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    tputVsPathLenFile=fat_tput_vs_pathlen_${NSW}_${NHOST}_${MAKE}_${OVERSUBSCRIPTION}_${TMatrix}_${BASHPID}
    rm -rf $tempFlowTputFile $tempFlowDistFile $tputVsPathLenFile
    cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k1 >> $tempFlowTputFile
    grep "mtcp_sink" $tempLogFile | awk '{split($2,arr,"_"); split(arr[7],sink,"=");  print sink[2] "  " arr[6];}' >> $tempFlowDistFile
    sort ${tempFlowDistFile} -o ${tempFlowDistFile}
    sort ${tempFlowTputFile} -o ${tempFlowTputFile}
    join -t' ' -1 1 -2 1 ${tempFlowTputFile} ${tempFlowDistFile} | awk '{print $2 " " $4}' >> ${tputVsPathLenFile}
    echo "Tput vs Pathlen: data dumped in file: $tputVsPathLenFile"
    echo "avg_throughput $tput"
    echo "avg_link_usage ${avg_link_usage}"
    #echo "avg_throughput $tput" > $tempResultFile
    rm $tempResultFile
    rm -rf ${link_bw_usage_file} ${tempFlowDistFile} ${tempLogFile}
    rm $tputVsPathLenFile
    #rm ${tempFlowTputFile}
fi


if [[ $1 == "LEAFSPINE" ]]; then
    #NHOST=`expr 3 \* $3 \* $3 / 4`
    #NSW=`expr 5 \* $3 / 4`
    SERVERS_PER_RACK=`expr $3 - $4`
    NHOST=`expr $3 \* ${SERVERS_PER_RACK}` 
    NSW=`expr $3 + $4`
    echo "$NHOST $NSW"
    OVERSUBSCRIPTION=$8
    NHOST=`expr $OVERSUBSCRIPTION \* $NHOST`
    if [[ $9 == "MAKE" ]]; then
        cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/0/g' | sed 's/P_SED/0/g' | sed 's/K_SED/'"$3"'/g' | sed 's/CHOSEN_TOPO_SED/'"$1"'/g' | sed 's/NUMPATHS_SED/0/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g' > main.h 
	 make leafspine
	 mv leafspine leafspine_${SUFFIX}
    fi
    PARAM2=`echo ${PARAM}| sed -e 's/\//$/g'`
    tempResultFile=leafspine_output_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    tempLogFile=leafspine_pathlog_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    echo $tempResultFile
    ./leafspine_${SUFFIX} -o ${tempLogFile} -sub $2 -TMatrix ${10} -mult ${MULT} -numerator ${NUMERATOR} -denominator ${DENOMINATOR} -solvestart ${SOLVESTART} -solveend ${SOLVEEND} -r ${ROUTING} -k ${KorN} -param ${PARAM} -paramo ${PARAMO} -seed ${SEED} -netpath ${NETPATH} -pathweight ${PATHWEIGHT} -dp ${DP} -mstart ${MSTART} -mend ${MEND} -stime ${STIME} -solveinterval ${SOLVEINTERVAL} -computestart ${COMPUTESTART} -computeend ${COMPUTEEND} -computeinterval ${COMPUTEINTERVAL} | tee $tempResultFile
    #cat leafspine_output | grep Throughput | awk -F " " '{thr[$5]=$2} END{for(sid in thr) print thr[sid]}' | awk -v nhost="$NHOST" '{sum+=$1} END{print sum/nhost/61}'
    #echo $tempResultFile
    #cat $tempResultFile | grep "Throughput" | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); print arr[1] " " thr[sid];}}'  | sort -n -k1 | awk -v nhost="$NHOST" '{sum[$1]+=$2} END{for(s in sum) print s,sum[s]/nhost/61}' | sort -n 
    tput=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); print arr[1] " " thr[sid];}}'  | sort -n -k1 | awk -v nhost="$NHOST" '{sum[$1]+=$2} END{for(s in sum) print s,sum[s]/nhost/61}' | sort -n | awk ' END { print } ' | awk '{ sum += $2 } END { if (NR > 0) print sum / NR }'`
    tput2=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k1 | awk -v nhost="$NHOST" '{ sum += $2 } END { print sum/nhost }'`
    tput_10ile=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k2 | awk -v nhost="$NHOST" '{all[NR] = $2} END{print (NR*all[int(NR*0.10 - 0.5)])/nhost}'`
    link_bw_usage=`cat $tempResultFile | grep "Link Usage" | awk '{print $6}'`
    link_bw_usage_file=leafspine_link_bw_usage_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    rm -rf ${link_bw_usage_file}
    echo "${link_bw_usage}" >> ${link_bw_usage_file}
    avg_link_usage=`awk '{ total += $1 } END { print (total/NR)/61 }' ${link_bw_usage_file}`
    tempFlowTputFile=leafspine_flowtput_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    tempFlowDistFile=leafspine_flowdist_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    #tputVsPathLenFile=leafspine_tput_vs_pathlen_$2_$3_$NHOST_$NSW_$9_${10}_${PARAM2}_${BASHPID}
    tputVsPathLenFile=leafspine_tput_vs_pathlen_${NSW}_${NHOST}_${MAKE}_${OVERSUBSCRIPTION}_${TMatrix}_${BASHPID}
    rm -rf $tempFlowTputFile $tempFlowDistFile $tputVsPathLenFile
    cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k1 >> $tempFlowTputFile
    grep "mtcp_sink" $tempLogFile | awk '{split($2,arr,"_"); split(arr[7],sink,"=");  print sink[2] "  " arr[6];}' >> $tempFlowDistFile
    sort ${tempFlowDistFile} -o ${tempFlowDistFile}
    sort ${tempFlowTputFile} -o ${tempFlowTputFile}
    join -t' ' -1 1 -2 1 ${tempFlowTputFile} ${tempFlowDistFile} | awk '{print $2 " " $4}' >> ${tputVsPathLenFile}
    echo "Tput vs Pathlen: data dumped in file: $tputVsPathLenFile"
    echo "avg_throughput $tput"
    echo "10ile_throughput $tput_10ile"
    echo "avg_link_usage ${avg_link_usage}"
    #echo "avg_throughput $tput" > $tempResultFile
    #rm $tempResultFile
    rm $tputVsPathLenFile ${tempFlowDistFile}
    rm -rf ${tempFlowTputFile}
    rm -rf ${link_bw_usage_file} ${tempLogFile}
fi


if [[ $1 == "RRG" ]]; then
    echo "RRG"
    NSW=`basename "$5" | awk -F "_" '{print $2}'`
    #echo $NSW
    #NNP=`echo "$5" | awk -F "_" '{split($3,out,"."); print out[1]}'`
    K=`basename "$5" | awk -F "_" '{split($3,out,"."); print out[1]}'`
    #K=`basename "$5" | awk -F "_" '{print $3}'`
    #NHOST=`basename "$5" | awk -F "_" '{split($4,out,"."); print out[1]}'`
    NHOST=$6
    NPARTS=$7
    OVERSUBSCRIPTION=$8
    NHOST=`expr $OVERSUBSCRIPTION \* $NHOST`
    MAKE=${9}
    TMatrix=${10}
    #NHOST=`expr $NSW \* \( $3 - $NNP \)`
    echo $NSW
    echo $K
    echo $NHOST
    echo $NPARTS
    echo $PARAM
    echo $5
    echo "Params done"
    if [[ $MAKE == "MAKE" ]]; then
        cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/'"$NNP"'/g' | sed 's/P_SED/'"$3"'/g' | sed 's/K_SED/'"$K"'/g' | sed 's/CHOSEN_TOPO_SED/'"$1"'/g' | sed 's/NUMPATHS_SED/'"$4"'/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g'  > main.h
	make rrg
	cp rrg rrg_$SUFFIX
    fi
    PARAM2=`echo ${PARAM}| sed -e 's/\//$/g'`
    tempResultFile=$5_$1_$2_$3_$4_$6_$7_$9_${10}_${PARAM2}_${SUFFIX}_rrg_output_${BASHPID}_${ROUTING}_${KorN}_${MULT}
    tempLogFile=$5_$1_$2_$3_$4_$6_$7_$9_${10}_${PARAM2}_${SUFFIX}_rrg_pathlog_${BASHPID}_${ROUTING}_${KorN}_${MULT}
    echo $tempResultFile
    echo ${PARAM}
    echo ${PARAMO}
    ./rrg_$SUFFIX -o ${tempLogFile} -sub $2 -TMatrix ${TMatrix} -mult ${MULT} -numerator ${NUMERATOR} -denominator ${DENOMINATOR} -solvestart ${SOLVESTART} -solveend ${SOLVEEND} -r ${ROUTING} -k ${KorN} -param ${PARAM} -paramo ${PARAMO} -topo $5 -seed ${SEED} -netpath ${NETPATH} -pathweight ${PATHWEIGHT} -dp ${DP} -mstart ${MSTART} -mend ${MEND} -stime ${STIME} -solveinterval ${SOLVEINTERVAL} -computestart ${COMPUTESTART} -computeend ${COMPUTEEND} -computeinterval ${COMPUTEINTERVAL} | tee $tempResultFile
    #cat rrg_output | grep Throughput | awk -F " " '{thr[$7][$5]=$2} END{for(i=1; i<=10; i++) for(sid in thr[i]) print i,thr[i][sid]}' | awk -v nhost="$NHOST" -F " " '{sum[$1]+=$2} END{for(s in sum) print sum[s]/nhost/61}'
    tput=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); print arr[1] " " thr[sid];}}'  | sort -n -k1 | awk -v nhost="$NHOST" '{sum[$1]+=$2} END{for(s in sum) print s,sum[s]/nhost/61}' | sort -n | awk ' END { print } ' | awk '{ sum += $2 } END { if (NR > 0) print sum / NR }'`
    tput2=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k1 | awk -v nhost="$NHOST" '{ sum += $2 } END { print sum/nhost }'`
    tput_10ile=`cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k2 | awk -v nhost="$NHOST" '{all[NR] = $2} END{print (NR*all[int(NR*0.10 - 0.5)])/nhost}'`
    tempFlowTputFile=$5_$1_$2_$3_$4_$6_$7_$9_${10}_${PARAM2}_${SUFFIX}_rrg_flowtput_${BASHPID}
    tempFlowDistFile=$5_$1_$2_$3_$4_$6_$7_$9_${10}_${PARAM2}_${SUFFIX}_rrg_flowdist_${BASHPID}
    #tputVsPathLenFile=$5_$1_$2_$3_$4_$6_$7_$9_${10}_${PARAM2}_${SUFFIX}_rrg_tput_vs_pathlen_${BASHPID}
    tputVsPathLenFile=${NSW}_${NHOSTS}_${MAKE}_${OVERSUBSCRIPTION}_${TMatrix}_rrg_tput_vs_pathlen_${BASHPID}
    rm -rf $tempFlowTputFile $tempFlowDistFile $tputVsPathLenFile
    cat $tempResultFile | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); flow[arr[2]]+=thr[sid];cnt[arr[2]]+=1;}; for(fl in flow) {print fl " " flow[fl]/cnt[fl]/61 " " cnt[fl]};}'  | sort -n -k1 >> $tempFlowTputFile
    grep "mtcp_sink" $tempLogFile | awk '{split($2,arr,"_"); split(arr[7],sink,"=");  print sink[2] "  " arr[6];}' >> $tempFlowDistFile
    sort ${tempFlowDistFile} -o ${tempFlowDistFile}
    sort ${tempFlowTputFile} -o ${tempFlowTputFile}
    join -t' ' -1 1 -2 1 ${tempFlowTputFile} ${tempFlowDistFile} | awk '{print $2 " " $4}' >> $tputVsPathLenFile
    link_bw_usage=`cat $tempResultFile | grep "Link Usage" | awk '{print $6}'`
    link_bw_usage_file=$5_$1_$2_$3_$4_$6_$7_$9_${10}_${PARAM2}_${SUFFIX}_link_bw_usage_${BASHPID}
    rm -rf ${link_bw_usage_file}
    echo "$link_bw_usage" >> $link_bw_usage_file
    avg_link_usage=`awk '{ total += $1 } END { print (total/NR)/61 }' ${link_bw_usage_file}`
    #echo "Tput vs Pathlen: data dumped in file: $tputVsPathLenFile"
    echo "Flow distribution: data dumped in file: $tempFlowDistFile"
    echo "avg_throughput $tput"
    #echo "avg_throughput2 $tput2"
    echo "10ile_throughput $tput_10ile"
    echo "avg_link_usage ${avg_link_usage}"
    echo "temporary result file ${tempResultFile}"
    rm -rf ${tempResultFile}
    rm -rf ${link_bw_usage_file} ${tempFlowDistFile} 
    rm -rf ${tputVsPathLenFile}
    rm -rf ${tempFlowTputFile}
    rm -rf ${tempLogFile}
fi
