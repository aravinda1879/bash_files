#! /bin/bash
source ../namd_variables.sh
cat << EOF > $tcl_f7
package require solvate
solvate -minmax {{-${cubic_box_vec} -${cubic_box_vec} -${cubic_box_vecz}} {${cubic_box_vec} ${cubic_box_vec} ${cubic_box_vecz}}} -o ${cubic_box_vec}_wb -s WW
#solvate ../${psf_f} ../${pdb_f} -spdb ${cubic_box_vec}_wb.pdb -spsf ${cubic_box_vec}_wb.psf -o ${infile}_wb
exit
EOF

cat << EOF > $tcl_f8
package require solvate
solvate ../${psf_f} ../${pdb_f} -spdb ${cubic_box_vec}_wb.pdb -spsf ${cubic_box_vec}_wb.psf -s WT -o ${infile}_pre_wb 
exit
EOF

cat << EOF > $tcl_f9
mol load psf "${infile}_pre_wb.psf"
mol addfile "${infile}_pre_wb.pdb"
set sel [atomselect top "all and not ((water and same residue as (within 2.4 of (all not water))))"]
\$sel writepsf ${infile}_wb.psf
\$sel writepdb ${infile}_wb.pdb
exit
EOF
