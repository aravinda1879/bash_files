echo "making the template for psfgen"
toppar_dir="/home/terabithia/bash/toppar"
cat << EOF > psfgen_template.tcl
#to apply symmetry operation add mono2poly.tcl
package require psfgen
topology ${toppar_dir}/top_all36_prot.rtf
topology ${toppar_dir}/toppar_water_ions.str

pdbalias residue HIE HSE
pdbalias residue HID HSD
pdbalias residue HIP HSP
pdbalias residue CYX CYS
pdbalias residue HOH TIP3
pdbalias atom HOH O OH2

pdbalias atom ILE CD1 CD
pdbalias residue HOH TIP3

set pro_lst  [list "in_pdb" ""]
set seg_lst  [list  "U1" "" ]
set outfile ""
#yes or no for hmr
set hmr "yes"   


foreach in_pdb \${pro_lst} seg \${seg_lst} {

#segment loading 
segment \$seg { first none; last CTER; pdb \${in_pdb} }

#coord section
coordpdb \${in_pdb} \${seg}

}
guesscoord
writepdb temp.pdb
writepsf temp.psf 
mol load psf temp.psf pdb temp.pdb
rm temp.psf 
rm temp.pdb 
foreach seg \${seg_lst} {

##patches 
#Nterminal
set t_sel [atomselect top "protein and segname \${seg} "]

set resname_lst [ \${t_sel} get resname]
if { [lindex \${resname_lst} 0] == "GLY" } {
patch GLYP \${seg}:[lindex [\${t_sel} get resid] 0]
} elseif { [lindex \${resname_lst} 0] == "PRO"} {
patch PROP \${seg}:[lindex [\${t_sel} get resid] 0] 
} else {
patch NTER \${seg}:[lindex [\${t_sel} get resid] 0]
}
}
\${t_sel} delete
#disulfide if any
set t_sel [atomselect top "protein and name SG "]
if { [llength [\$t_sel get index]] > 1 } {
set sslst [\${t_sel} get index]
set ssdone [list ]
foreach ss \$sslst  {
if {[lsearch -exact \$ssdone "\$ss"] < 0} { 
set a [atomselect top " index \$ss" ]
set b [atomselect top "(index \$sslst ) and exwithin 5.1 of index \$ss"]
if { [\$b get index ] == "" } {
continue
} else {
patch DISU   [\$a get segname ]:[\$a get resid ] [\$b get segname ]:[\$b get resid ] 
lappend ssdone [\$a get index] [\$b get index]
}
}
}
}
if { \$hmr == "yes" } {
hmassrepart dowater 0
}
guesscoord 
writepdb \${outfile}.pdb 
writepsf \${outfile}.psf
quit 
EOF


