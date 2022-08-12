#! /bin/bash
source ../namd_variables.sh
cat << EOF > colvar_pdbmaker.tcl
set mol [mol new "${infile}_wb.psf" type psf waitfor all]
mol addfile "${infile}_wb.pdb" waitfor all molid \$mol
set all [atomselect top "all"] 
set sel1 [atomselect top "$atom_selection_grp1"] 
set sel2 [atomselect top "$atom_selection_grp2"] 
\$all set occupancy 0.0 
\$sel1 set occupancy 1.0 
\$sel2 set occupancy 2.0 
#\$all writepdb $pdb_f
animate write pdb colvar.pdb sel \$all top
EOF
vmd -dispdev text -eofexit < colvar_pdbmaker.tcl > temp.log
rm temp.log

