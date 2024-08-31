\ Model mcf
\ LP format - for model browsing. Use MPS format to capture full model detail.
Maximize
  k
Subject To
 c0_0_2: 0_2_0 + 0_2_1 - 0.0001 k >= 0
 c0_1_2: 1_2_0 - 8e-05 k >= 0
 c1_0_1: 0_2_1 <= 1
 c1_0_2: 0_2_0 <= 1
 c1_1_2: 0_2_1 + 1_2_0 <= 1
Bounds
End
