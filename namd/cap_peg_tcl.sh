#! /bin/bash
source ~/bash/namd/charmm_lib.sh
ls
echo "Please enter the peg pdb name"
read peg_pdb
cat << EOF > peg_cap.tcl
package require psfgen
topology ${pol_rtf}
segment U3 { first GCL0; last GCL3;pdb ${peg_pdb}}
coordpdb ${peg_pdb} U3
guesscoord
writepdb ${peg_pdb//.pdb}_cap.pdb
quit
EOF
vmd -dispdev text -eofexit < peg_cap.tcl > output_cap_peg.log
