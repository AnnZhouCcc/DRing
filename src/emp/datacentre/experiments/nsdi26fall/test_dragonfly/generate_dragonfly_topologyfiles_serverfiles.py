p = 2
a = 3
h = 1

topologyfile = f"tpfiles/df_p{p}_a{a}_h{h}.edgelist"
serverfile = f"svfiles/df_p{p}_a{a}_h{h}.sv"

nswitches = a*(a*h+1)

with open(serverfile,'w') as fserver:
    # Switch → Host and Host → Switch links
    for j in range(nswitches):
        for l in range(p):
            k = j * p + l
            fserver.write(f"{k},{j}\n")

with open(topologyfile,'w') as ftopo:
    # Switch ↔ Switch links
    for j in range(nswitches):
        groupid = j // a

        # Intra-group full mesh
        for k in range(j + 1, (groupid + 1) * a):
            ftopo.write(f"{k}->{j}\n")

        # Global links (inter-group)
        for l in range(h):
            targetgroupid = (j % a) * h + l
            larger = targetgroupid >= groupid
            if larger:
                targetgroupid += 1
            else:
                continue

            k = targetgroupid * a + groupid // h

            ftopo.write(f"{k}->{j}\n")
