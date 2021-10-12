TOPO=RRG
NHOST=3072 # 2988 for DRing, 3072 for RRG
TOPOFILE="graphfiles/ring_supergraph/rrg/instance1_80_64.edgelist"
MAKE="MAKE"
ROUTING=ecmp
KorN=0

TMatrix="RANDOM"
PARAM=8
PARAMO=0
MULT=1
NUMERATOR=0
DENOMINATOR=0
SUFFIX=${NHOST}_${ROUTING}_${KorN}
NSW=80
P=64
K=64
NUMPATHS=16
NPARTS=1
OVERSUBSCRIPTION=1
PARTITION=FALSE
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
    rm storenetpath
    rm storenetpath_$SUFFIX
    cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/'"$NNP"'/g' | sed 's/P_SED/'"$P"'/g' | sed 's/K_SED/'"$K"'/g' | sed 's/CHOSEN_TOPO_SED/'"$TOPO"'/g' | sed 's/NUMPATHS_SED/'"$NUMPATHS"'/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g'  > main.h
    make storenetpath
    cp storenetpath storenetpath_$SUFFIX
fi
PARAM2=`echo ${PARAM}| sed -e 's/\//$/g'`
tempResultFile=${PARAM2}_${SUFFIX}_rrg_output_${BASHPID}_${ROUTING}_${KorN}_${MULT}
tempLogFile=${PARAM2}_${SUFFIX}_rrg_pathlog_${BASHPID}_${ROUTING}_${KorN}_${MULT}
echo $tempResultFile
echo ${PARAM}
echo ${PARAMO}
./storenetpath_$SUFFIX -o ${tempLogFile} -sub ${SUB} -TMatrix ${TMatrix} -mult ${MULT} -numerator ${NUMERATOR} -denominator ${DENOMINATOR} -r ${ROUTING} -k ${KorN} -param ${PARAM} -paramo ${PARAMO} -topo ${TOPOFILE} -seed ${SEED} | tee $tempResultFile

echo "temporary result file ${tempResultFile}"
rm -rf ${tempResultFile}
rm -rf ${tempLogFile}
