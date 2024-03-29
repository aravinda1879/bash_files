# run with his_disulfide_psfgen.sh
echo "DO NOT RUN ALONE"
echo "Splitting chains into different segments and creeating disulfide bond files"
in_pdb=${1//.pdb}
cat << EOF > pdb_seg_seperate.tcl
mol new ${in_pdb}.pdb 
set all [atomselect top all]
#set seg_lst [lsort -unique [\$all get chain] ]
set seg_lst [lsort -unique [\$all get segname] ]

foreach seg \$seg_lst {
#for chain
#set t_sel [atomselect top "protein and chain \$seg"]
#set t_sel2 [atomselect top "not protein and not water and chain \$seg"]
#set wat [atomselect top "water and chain \$seg"]
#for seg
set t_sel [atomselect top "segname \$seg"]
set t_sel2 [atomselect top "not protein and not water and segname \$seg"]
set wat [atomselect top "water and segname \$seg"]

\${t_sel} writepdb ${in_pdb}_seg\${seg}.pdb 
\${t_sel2} writepdb ${in_pdb}_lig_seg\${seg}.pdb
\${wat} writepdb ${in_pdb}_wat_seg\${seg}.pdb
}
EOF
vmd -dispdev text -eofexit <pdb_seg_seperate.tcl> seg_seperate.log  
