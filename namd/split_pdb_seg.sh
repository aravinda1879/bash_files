# run with his_disulfide_psfgen.sh
echo "DO NOT RUN ALONE"
echo "Splitting chains into different segments and creeating disulfide bond files"
in_pdb=${1//.pdb}
cat << EOF > pdb_seg_seperate.tcl
mol new ${in_pdb}.pdb 
set all [atomselect top all]
set seg_lst [lsort -unique [\$all get chain] ]
foreach seg \$seg_lst {
set t_sel [atomselect top "protein and chain \$seg"]
\${t_sel} writepdb ${in_pdb}_seg\${seg}.pdb 
}
EOF
vmd -dispdev text -eofexit <pdb_seg_seperate.tcl> seg_seperate.log  
