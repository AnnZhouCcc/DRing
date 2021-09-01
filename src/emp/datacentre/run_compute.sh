NSW=80
NNP=
P=64
K=64
CHOSEN_TOPO=RRG
NUMPATHS=16
NHOST=3072
OVERSUBSCRIPTION=1
rm computestore
cat main.h.template | sed 's/NSW_SED/'"$NSW"'/g' | sed 's/R_SED/'"$NNP"'/g' | sed 's/P_SED/'"$P"'/g' | sed 's/K_SED/'"$K"'/g' | sed 's/CHOSEN_TOPO_SED/'"$CHOSEN_TOPO"'/g' | sed 's/NUMPATHS_SED/'"$NUMPATHS"'/g' | sed 's/NHOST_SED/'"$NHOST"'/g' | sed 's/OVERSUBSCRIPTION_SED/'"$OVERSUBSCRIPTION"'/g'  > main.h
make computestore
./computestore
