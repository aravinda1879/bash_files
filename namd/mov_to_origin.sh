#! /bin/bash
source ../namd_variables.sh
cat << EOF > $tcl_f6
mol load pdb "../${pdb_f}"
set all [atomselect top "all"] 
set gec [measure center \$all] 
\$all moveby [vecscale -1.0 \$gec] 
\$all writepdb "../${pdb_f}" 
EOF
