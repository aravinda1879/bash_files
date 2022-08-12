mol new H1_kim_K12_mod0_noFold.pdb 
set all [atomselect top all]
#set seg_lst [lsort -unique [$all get chain] ]
set seg_lst [lsort -unique [$all get segname] ]
foreach seg $seg_lst {
#set t_sel [atomselect top "protein and chain $seg"]
#set t_sel2 [atomselect top "not protein and not water and chain $seg"]
#set wat [atomselect top "water and chain $seg"]
set t_sel [atomselect top "protein and segname $seg"]
#set t_sel2 [atomselect top "not protein and not water and segname $seg"]
#set wat [atomselect top "water and segname $seg"]

${t_sel} writepdb H1_kim_K12_mod0_noFold_seg${seg}.pdb 
#${t_sel2} writepdb H1_kim_K12_mod0_noFold_lig_seg${seg}.pdb
#${wat} writepdb H1_kim_K12_mod0_noFold_wat_seg${seg}.pdb
}
