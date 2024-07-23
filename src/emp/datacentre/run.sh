#!/bin/bash
# USAGE: ./run.sh [topology type] [# subflows] [total # ports] [# paths] [topologyfile] [nservers] [nclusters] [oversubscription] [make? MAKE: NOMAKE] [TM_Matrix:PERM/SAMPLED_PERM/STRIDE/STGD_PERM/HOT_SPOT/MANY_TO_MANY/RANDOM/MAX_WT/RACK_TO_RACK/RACK_PERM/ALL_TO_ALL/FEW_TO_SOME/ALL_TO_FEW/FILE/UNIFORM] [multiplier] [param:optional] [paramo:optional] [seed:optional] [suffix: optional] 

#rm -rf main.o fattree leafspine rrg

TOPO=$1 # RRG,LEAFSPINE
MAKE=$2 # MAKE,NOMAKE
NSW=$3 # total number of switches,80
NHOST=$4 # 3072,2988
K=$5 # number of ports == number of leaf switches,64
SUFFIX=$6 # eg,${topology}_${routing}_${trafficmatrix}_${mode}
TM=$7 # $trafficmatrixparam,A2A,S2S_1_1_0_0,F2F_16_4_0_1,PERM,CLUSTERX,refer to discover.sh L145-189
TOPOFILE=$8 # graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist,graphfiles/ring_supergraph/double_ring/instance1_80_64.edgelist,null
MULT=$9 
NUMERATOR=${10}
DENOMINATOR=${11} # the above three controls the amount of traffic injected into the network
SOLVESTART=${12}
SOLVEEND=${13}
SOLVEINTERVAL=${14}
COMPUTESTART=${15}
COMPUTEEND=${16}
COMPUTEINTERVAL=${17} # the above six decides what path weights to be used for cluster traffic
ROUTING=${18} 
KorN=${19} # $routingparam,ecmp,su,kdisjoint,kshort,racke; kornparam; eg, routingparam=su, kornparam=3
PARAM=${20} # $trafficfilename,a,b,c,null
SEED=${21}
NETPATH=${22} # $npfile,netpathfiles/netpath_${routing}_${topology}.txt
PATHWEIGHT=${23} # $pwfile,refer to discover.sh L94-124
DP=${24} # $precision,64
MSTART=${25}
MEND=${26}
STIME=${27} # the above three parameters are related to the simulation itself

OVERSUBSCRIPTION=1
SUBFLOW=1
PARAMO=0


if [[ $TOPO == "LEAFSPINE" ]]; then
    if [[ $MAKE == "MAKE" ]]; then
        cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/K_SED/'"$K"'/g' | sed 's/CHOSEN_TOPO_SED/'"$TOPO"'/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g' > main.h 
	 make leafspine
	 mv leafspine leafspine_${SUFFIX}_run
    fi

    tempLogFile=leafspine_log_${BASHPID}
    ./leafspine_${SUFFIX}_run -o ${tempLogFile} -sub $SUBFLOW -TMatrix ${TM} -mult ${MULT} -numerator ${NUMERATOR} -denominator ${DENOMINATOR} -solvestart ${SOLVESTART} -solveend ${SOLVEEND} -r ${ROUTING} -k ${KorN} -param ${PARAM} -paramo ${PARAMO} -seed ${SEED} -netpath ${NETPATH} -pathweight ${PATHWEIGHT} -dp ${DP} -mstart ${MSTART} -mend ${MEND} -stime ${STIME} -solveinterval ${SOLVEINTERVAL} -computestart ${COMPUTESTART} -computeend ${COMPUTEEND} -computeinterval ${COMPUTEINTERVAL}
    rm -rf ${tempLogFile}
fi

if [[ $TOPO == "RRG" ]]; then
    if [[ $MAKE == "MAKE" ]]; then
        cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/K_SED/'"$K"'/g' | sed 's/CHOSEN_TOPO_SED/'"$TOPO"'/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g'  > main.h
	make rrg
	mv rrg rrg_${SUFFIX}_run
    fi

    tempLogFile=rrg_log_${BASHPID}
    ./rrg_${SUFFIX}_run -o ${tempLogFile} -sub $SUBFLOW -TMatrix ${TM} -mult ${MULT} -numerator ${NUMERATOR} -denominator ${DENOMINATOR} -solvestart ${SOLVESTART} -solveend ${SOLVEEND} -r ${ROUTING} -k ${KorN} -param ${PARAM} -paramo ${PARAMO} -topo ${TOPOFILE} -seed ${SEED} -netpath ${NETPATH} -pathweight ${PATHWEIGHT} -dp ${DP} -mstart ${MSTART} -mend ${MEND} -stime ${STIME} -solveinterval ${SOLVEINTERVAL} -computestart ${COMPUTESTART} -computeend ${COMPUTEEND} -computeinterval ${COMPUTEINTERVAL}
    rm -rf ${tempLogFile}
fi
