#!/bin/bash
cat << EOF > var_list.sh
#"enter the ligand region eg:- 110-100,220-333"
export llist=
#"enter the receptor region"
export rlist=
#"enter a file name"
export fname=
#"Enter the complex region"
export clist=
#"enter the resid list of mutating"
export mlist=
#"enter the original topology file name with ../../xxx"
export ogtop=
#"Do you want the script (1) or command (2) ?"
export rep_scr=
#"enter the complex trajectory name (xxxx_5ps_strip_h2o_ion.nc)"
export nc_com=
#"Do you want to copy these files to gpu (y/n)"
export rep_copy=

### MMPBSA input file variables
#starting frame
export sframe=
#ending frame
export eframe=
#interval
export nsplit=
# value to begin each sub cycle
export fcyc=



#universal variables
export cptop=_complex_strip_ion_wat.prmtop
export lptop=_ligand_strip_ion_wat.prmtop
export rptop=_receptor_strip_ion_wat.prmtop
export radii=mbondi2
export mlptop=_mutated_ligand_vac.prmtop
export mcptop=_mutated_complex_vac.prmtop
export mrptop=_mutated_receptor_vac.prmtop

export wdir='pwd'

export t1="_temp_complex.pdb"
export t2="_temp_mligand.pdb"
export t2_2="mutated_protien.pdb"
export t3="_mutated_ligand"
export t4="_mutated_complex"
export t5="_initial_complex"
export t6="_mutated_complex.pdb"
export t7="_temp_mreceptor.pdb"
export t8="_mutated_receptor.pdb"
export t9="_mutated_complex.pdb"
EOF
