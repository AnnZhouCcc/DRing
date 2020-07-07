#!/bin/bash
# USAGE: ./run.sh [1. topology type] [2. # subflows] [3. total # ports] [4. # paths] [5. topologyfile] [6. FailRate]

FAIL_RATE="$6"
RUN="$7"

echo FAIL "$FAIL_RATE"

#rm -rf main.o fattree rrg
if [[ $1 == "FAT" ]]; then
	NHOST=`expr $3 \* $3 \* $3 / 4`
	NSW=`expr 5 \* $3 \* $3 / 4`
	cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/0/g' | sed 's/P_SED/0/g' | sed 's/K_SED/'"$3"'/g' | sed 's/CHOSEN_TOPO_SED/'"$1"'/g' | sed 's/NUMPATHS_SED/0/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/FAIL_RATE_SED/'"$FAIL_RATE"'/g' > main.h
	make fattree
	./fattree -o RESULT.out -sub $2 -param 1 | tee fat_output
	echo " "
	#cat fat_output | grep Throughput | awk -F " " '{thr[$5]=$2} END{for(sid in thr) print thr[sid]}' | awk -v nhost="$NHOST" '{sum+=$1} END{print sum/nhost/61}'
	cat fat_output | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); print arr[1] " " thr[sid];}}'  | sort -n -k1 | awk -v nhost="$NHOST" -v run=$RUN '{sum[$1]+=$2} END{for(s in sum) print RESULT run,s,sum[s]/nhost/61}' | sort -n
fi

if [[ $1 == "RRG" ]]; then
	echo "RRG"
	NSW=`basename "$5" | awk -F "_" '{print $2}'`
	#NNP=`echo "$5" | awk -F "_" '{split($3,out,"."); print out[1]}'`
	K=`basename "$5" | awk -F "_" '{print $3}'`
	NHOST=`basename "$5" | awk -F "_" '{split($4,out,"."); print out[1]}'`
	#NHOST=`expr $NSW \* \( $3 - $NNP \)`
	cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/'"$NNP"'/g' | sed 's/P_SED/'"$3"'/g' | sed 's/K_SED/'"$K"'/g' | sed 's/CHOSEN_TOPO_SED/'"$1"'/g' | sed 's/NUMPATHS_SED/'"$4"'/g' | sed 's/NHOST_SED/'"$NHOST"'/g' > main.h
	make rrg
	./rrg -o RESULT.out -sub $2 -param 1 -topo $5 | tee rrg_output
	echo " "
	#cat rrg_output | grep Throughput | awk -F " " '{thr[$7][$5]=$2} END{for(i=1; i<=10; i++) for(sid in thr[i]) print i,thr[i][sid]}' | awk -v nhost="$NHOST" -F " " '{sum[$1]+=$2} END{for(s in sum) print sum[s]/nhost/61}'
	cat rrg_output | grep Throughput | awk -F " " '{thr[$7 " " $5]=$2} END{for(sid in thr) {split(sid,arr," "); print arr[1] " " thr[sid];}}'  | sort -n -k1 | awk -v nhost="$NHOST" '{sum[$1]+=$2} END{for(s in sum) print s,sum[s]/nhost/61}' | sort -n
fi
