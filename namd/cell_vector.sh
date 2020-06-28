#! /bin/bash
source ../namd_variables.sh
#only calculating the cell coordinates using water 
cat << EOF > $tcl_f1
mol load pdb "${infile}_wb.pdb"
proc get_cell {{molid top}} { 
 set output [open "_1.dat" w]
 set all [atomselect \$molid "water"] 
 set minmax [measure minmax \$all] 
 set vec [vecsub [lindex \$minmax 1] [lindex \$minmax 0]] 
 puts \$output "cellBasisVector1 [lindex \$vec 0] 0 0" 
 puts \$output "cellBasisVector2 0 [lindex \$vec 1] 0" 
 puts \$output "cellBasisVector3 0 0 [lindex \$vec 2]" 
 set center [measure center \$all] 
 puts \$output "cellOrigin \$center" 
 close \$output
 \$all delete 
} 
get_cell
EOF

