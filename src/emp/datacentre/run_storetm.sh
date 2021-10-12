TOPO=RRG
NHOST=3072 # 2988 for DRing, 3072 for RRG
TOPOFILE="graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist"
MAKE="MAKE"
TMatrix="RACK_TO_RACK"
PARAM=48 # "graphfiles/ring_supergraph/ls_x48_y16_${tm}.data"
PARAMO=48
MULT=1
NUMERATOR=0
DENOMINATOR=0

SUFFIX=${NHOST}_${TMatrix}
NSW=80
P=64
K=64
NUMPATHS=16
NPARTS=1
OVERSUBSCRIPTION=1
PARTITION=FALSE
ROUTING=ecmp
KorN=0
SEED=3
SUB=1

echo "RRG"
echo $NSW
echo $K
echo $NHOST
echo $NPARTS
echo $PARAM
echo "Params done"

if [[ $MAKE == "MAKE" ]]; then
    rm storetm_$SUFFIX
    cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/'"$NNP"'/g' | sed 's/P_SED/'"$P"'/g' | sed 's/K_SED/'"$K"'/g' | sed 's/CHOSEN_TOPO_SED/'"$TOPO"'/g' | sed 's/NUMPATHS_SED/'"$NUMPATHS"'/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g'  > main.h
    make storetm
    cp storetm storetm_$SUFFIX
fi
PARAM2=`echo ${PARAM}| sed -e 's/\//$/g'`
tempResultFile=${PARAM2}_${SUFFIX}_rrg_output_${BASHPID}_${ROUTING}_${KorN}_${MULT}
tempLogFile=${PARAM2}_${SUFFIX}_rrg_pathlog_${BASHPID}_${ROUTING}_${KorN}_${MULT}
echo $tempResultFile
echo ${PARAM}
echo ${PARAMO}
./storetm_$SUFFIX -o ${tempLogFile} -sub ${SUB} -TMatrix ${TMatrix} -mult ${MULT} -numerator ${NUMERATOR} -denominator ${DENOMINATOR} -r ${ROUTING} -k ${KorN} -param ${PARAM} -paramo ${PARAMO} -topo ${TOPOFILE} -seed ${SEED} | tee $tempResultFile

echo "temporary result file ${tempResultFile}"
rm -rf ${tempResultFile}
rm -rf ${tempLogFile}
