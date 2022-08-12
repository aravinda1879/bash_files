#!/bin/bash
#This includes all the files names seperately to reduce the file size of the original script
cat << EOF > namd_variables.sh
#inputs for
cluster=$4
# common variables
export infile=${infile}
psf_f=${infile0}.psf
pdb_f=${infile0}.pdb
tcl_f0=bsa_25peg_solvation.tcl
tcl_f1=cell_vectors.tcl
tcl_f2=constrain_pdb.tcl
#(only for vacum)
tcl_f2_1=constrain_pdb_vac.tcl 
tcl_f3=neutralize.tcl
tcl_f4=bin2pdb.tcl
tcl_f5=smd_atm.tcl
tcl_f6=move_to_origin.tcl
tcl_f7=var_wat_cube.tcl
tcl_f8=var_wat_cube_add.tcl
tcl_f9=var_wat_cube_add_rmv_overlap.tcl
export conf_min1_f=${infile}_wb_min_1.conf
export conf_min2_f=${infile}_wb_min_2.conf
export conf_heat_eq_f=${infile}_wb_heat_eq.conf
export conf_pro_f=${infile}_wb_md1.conf

out_file_eq=${infile}_wb_eq
out_file_pro=${infile}_wb_md
# defining directories
dir2=project_prep_${infile}
dir3=project_run_${infile}

EOF
