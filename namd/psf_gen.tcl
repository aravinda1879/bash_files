package require psfgen
topology top_all36_prot.rtf
topology top_all35_ethers-oh.rtf
topology oxm_wt_cap.inp
topology patch.inp
topology top_all36_cgenff.rtf
pdbalias residue HIS HSE
pdbalias atom ILE CD1 CD
pdbalias residue HOH TIP3
segment U1 {first none; last CTER; pdb bsa_chain_a_oxm.pdb}
segment U2  {pdb oxm_cap.pdb}
segment U3 { first GCL0; last GCL3; pdb peg100_c.pdb}
patch OXCTER U1:2 U2:0
patch OXNTER U2:0 U3:1
coordpdb bsa_chain_a_oxm.pdb U1
coordpdb oxm_cap.pdb U2
coordpdb peg100_c.pdb U3
guesscoord
writepdb final_1.pdb
writepsf final_1.psf
quit
