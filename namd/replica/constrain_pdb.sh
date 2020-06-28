#! /bin/bash
source ../namd_variables.sh
cat << EOF > $tcl_f2
set mol [mol new "$psf_f" type psf waitfor all]
mol addfile "$Bincoordinates" waitfor all molid \$mol
set all [atomselect top "all"] 
set sel [atomselect top "$rest2_sel"] 
\$all set occupancy 0.0 
\$sel set occupancy 1.0 
\$all writepdb $pdb_f
EOF
