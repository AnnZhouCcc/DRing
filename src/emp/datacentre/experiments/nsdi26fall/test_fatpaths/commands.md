(run for 99m, max_extra_hop=2)
(venv) az6922@netsyn-01:/mnt/mirabelle/az6922_homedir/DRing/src/emp/datacentre$ cp experiments/
nsdi26fall/test_fatpaths/npfiles/netpath_dring_80_64_fatpaths.np evalnetpathfiles/netpath_dring_80_64_fatpaths.np

python3 generate_fatpaths_pathweightfiles.py --graphfile ../../../evaltopologyfiles/dring_80_64.edgelist --serverfile ../../../evalserverfiles/dring_2988_80_64.sv --numsw 80 --numserver 2988 --netpathfile npfiles/netpath_dring_80_64_fatpaths.np --flowfile cmfiles/fiveflow.cm --flowstart 0 --flowend 10 --numfaillink 0 --linkfailurefile "" --varfile pwfiles/pathtraffic_dring_80_64_fatpaths.txt --qvarfile pwfiles/pathweight_dring_80_64_fatpaths.txt