#! /bin/bash
source ../namd_variables.sh
cat << EOF > $tcl_f2
mol load pdb "ionized.pdb"
set all [atomselect top "all"] 
set sel [atomselect top "protein backbone"] 
\$all set beta 0.0 
\$sel set beta 1.0 
\$all writepdb restraint.pdb 
EOF
