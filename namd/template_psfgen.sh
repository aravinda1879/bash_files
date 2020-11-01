echo "making the template for psfgen"
toppar_dir="/home/terabithia/bash/toppar"
tcl_dir="/home/terabithia/bash/namd" 
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
pdbalias atom NAG C8 CT
pdbalias atom NAG O7 O
pdbalias atom NAG C7 C
pdbalias atom NAG N2 N

pdbalias atom ILE CD1 CD
pdbalias residue HOH TIP3

#if there are glycans, use H and chain name.
set pdbname "2viu.pdb"
set chain_lst [list A B C D E F]
set pro_lst  [list "4kdq_segA_R.pdb" "4kdq_segB_R.pdb" "4kdq_segC_R.pdb" "4kdq_segD_R.pdb" "4kdq_segE_R.pdb" "4kdq_segF_R.pdb"]
set pro_seg_lst  [list  "HA" "HB"  "HC" "HD"  "HE" "HF" ]
set lig_lst  [list "4kdq_lig_segA.pdb" "4kdq_lig_segB.pdb" "4kdq_lig_segC.pdb" "4kdq_lig_segD.pdb" "4kdq_lig_segE.pdb" "4kdq_lig_segF.pdb"  ]
set lig_seg_lst  [list  "SA" "SB" "SC" "SD" "SE" "SF" ]
set wat_lst  [list  "4kdq_wat_segA.pdb" "4kdq_wat_segB.pdb" "4kdq_wat_segC.pdb" "4kdq_wat_segD.pdb" "4kdq_wat_segE.pdb" "4kdq_wat_segF.pdb"  ]
set wat_seg_lst  [list  "WA" "WB" "WC" "WD" "WE" "WF" ]

set outfile "test2"
#yes or no for all 
set hmr "yes"   
set need_unitcell "yes"
set need_glycan "yes"

if {\$need_glycan == "yes" } {
source ${tcl_dir}/glycan.tcl
topology ${toppar_dir}/nag-bma-man.str  
topology ${toppar_dir}/toppar_all36_carb_glycopeptide.str
topology ${toppar_dir}/top_all36_carb.rtf 
#make sure to remove glycans whihc not bound to protein 
set gly_lst [parseglycan \$pdbname]
set gly_lst [lreplace \$gly_lst 0 0]
}

#Adding protein segments
foreach in_pdb \${pro_lst} seg \${pro_seg_lst} {
segment \$seg { first none; last CTER; pdb \${in_pdb} }
coordpdb \${in_pdb} \${seg}
}
#Adding ligand segments
if { [llength \$lig_lst ] != 0 }  {
foreach in_pdb \${lig_lst} seg \${lig_seg_lst} {
segment \$seg { first none; last none; pdb \${in_pdb} }
coordpdb \${in_pdb} \${seg}
}
}
#Adding protein segments
if {  [llength \$wat_lst ] != 0 } {
foreach in_pdb \${wat_lst} seg \${wat_seg_lst} {
segment \$seg { first none; last none; pdb \${in_pdb} }
coordpdb \${in_pdb} \${seg}
}
}

guesscoord
writepdb temp.pdb
writepsf temp.psf 

#######
mol load psf temp.psf pdb temp.pdb
rm temp.psf 
rm temp.pdb 

foreach seg \${pro_seg_lst} {

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
} elseif { [lsearch [lindex [\$b getbonds ] 0]  "\$ss" ] > 0  } {
#this section checks if the atom already bonds to selected index
continue 
} else {
patch DISU   [\$a get segname ]:[\$a get resid ] [\$b get segname ]:[\$b get resid ] 
lappend ssdone [\$a get index] [\$b get index]
}
}
}
}

### GLycan addition if needed
if {\$need_glycan == "yes" } {
#this only works as long as link definition carries chains in order
#also only supprts linkers via C1 
foreach link  \$gly_lst  {
if { [lindex \$link  0] == "C1" } {
  if       { [lindex \$link  4] == "ND2" } { 
    patch NGLA H[lindex \$link 6]:[lindex \$link  7] S[lindex \$link   2]:[lindex \$link  3]
  } elseif { [lindex \$link  4] == "NE2"  } {
    patch QGLA H[lindex \$link 6]:[lindex \$link  7] S[lindex \$link   2]:[lindex \$link  3] 
  } elseif { [lindex \$link  4] == "O1" } {
    patch 11aa S[lindex \$link 6]:[lindex \$link  7] S[lindex \$link   2]:[lindex \$link  3] 
  } elseif { [lindex \$link  4] == "O2" } {
    patch 12aa S[lindex \$link 6]:[lindex \$link  7] S[lindex \$link   2]:[lindex \$link  3]
  } elseif { [lindex \$link  4] == "O3" } {
    patch 13aa S[lindex \$link 6]:[lindex \$link  7] S[lindex \$link   2]:[lindex \$link  3]
  } elseif { [lindex \$link  4] == "O4" } {
    patch 14aa S[lindex \$link 6]:[lindex \$link  7] S[lindex \$link   2]:[lindex \$link  3]
  } elseif { [lindex \$link  4] == "O6" } {
    patch 16aa S[lindex \$link 6]:[lindex \$link  7] S[lindex \$link   2]:[lindex \$link  3]
  } else {
    puts "WARNING: patch not found"
  }
} elseif { [lindex \$link  4] == "C1" } { 
  if       { [lindex \$link  0] == "ND2" } { 
    patch NGLA H[lindex \$link   2]:[lindex \$link  3] S[lindex \$link  6]:[lindex \$link  7]
  } elseif { [lindex \$link  0] == "NE2"  } {
    patch QGLA H[lindex \$link   2]:[lindex \$link  3] S[lindex \$link 6]:[lindex \$link  7] 
  } elseif { [lindex \$link  0] == "O1" } {
    patch 11aa S[lindex \$link   2]:[lindex \$link  3] S[lindex \$link 6]:[lindex \$link  7] 
  } elseif { [lindex \$link  0] == "O2" } {
    patch 12aa S[lindex \$link   2]:[lindex \$link  3] S[lindex \$link 6]:[lindex \$link  7]
  } elseif { [lindex \$link  0] == "O3" } {
    patch 13aa S[lindex \$link   2]:[lindex \$link  3] S[lindex \$link 6]:[lindex \$link  7]
  } elseif { [lindex \$link  0] == "O4" } {
    patch 14aa S[lindex \$link   2]:[lindex \$link  3] S[lindex \$link 6]:[lindex \$link  7]
  } elseif { [lindex \$link  0] == "O6" } {
    patch 16aa S[lindex \$link   2]:[lindex \$link  3] S[lindex \$link 6]:[lindex \$link  7]
  } else {
    puts "WARNING: patch not found"
  }
}
}
}

### hydrogen mass repartition
if { \$hmr == "yes" } {
hmassrepart dowater 0
}
regenerate angles dihedrals
guesscoord 
writepdb \${outfile}.pdb 
writepsf \${outfile}.psf

### biological unit operation
if { \$need_unitcell == "yes" } {
mol delete top
mol load psf \${outfile}.psf pdb \${outfile}.pdb

source ${tcl_dir}/mono2poly.tcl 
set matrix [parsematrix \${pdbname}]
set sel [atomselect top all]
mono2poly -o test3 \$sel \$matrix


mol delete top

#merging three structures 
package require topotools 
# load to be merged molecules into VMD
set midlist {}

for {set i 0} {\$i < [llength \$matrix]} {incr i} {
set mol [mol new \${outfile}.psf waitfor all]
mol addfile test3.\${i}.pdb
foreach seg [lsort -unique [[atomselect top all] get segname]] {
set tmp [atomselect top "segname \${seg}"]
\$tmp set segname \${seg}\${i}
}
lappend midlist \$mol
}

# do the magic
set mol [::TopoTools::mergemols \$midlist]
animate write psf \${outfile}.psf \$mol
animate write pdb \${outfile}.pdb \$mol
}

quit 
EOF


