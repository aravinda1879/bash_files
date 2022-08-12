#to apply symmetry operation add mono2poly.tcl
package require psfgen
topology /home/aravinda1879/bash/toppar/top_all36_prot.rtf
topology /home/aravinda1879/bash/toppar/toppar_water_ions.str

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
set pro_lst  [list "H1_kim_WT_noFold_segHA11_R.pdb" "H1_kim_WT_noFold_segHA21_R.pdb" "H1_kim_WT_noFold_segHA12_R.pdb" "H1_kim_WT_noFold_segHA22_R.pdb" "H1_kim_WT_noFold_segHA13_R.pdb" "H1_kim_WT_noFold_segHA23_R.pdb"]
set pro_seg_lst  [list  "HA11" "HA21"  "HA12" "HA22"  "HA13" "HA23" ]
#set lig_lst  [list "4kdq_lig_segA.pdb" "4kdq_lig_segB.pdb" "4kdq_lig_segC.pdb" "4kdq_lig_segD.pdb" "4kdq_lig_segE.pdb" "4kdq_lig_segF.pdb"  ]
#set lig_seg_lst  [list  "SA" "SB" "SC" "SD" "SE" "SF" ]
#set wat_lst  [list  "4kdq_wat_segA.pdb" "4kdq_wat_segB.pdb" "4kdq_wat_segC.pdb" "4kdq_wat_segD.pdb" "4kdq_wat_segE.pdb" "4kdq_wat_segF.pdb"  ]
#set wat_seg_lst  [list  "WA" "WB" "WC" "WD" "WE" "WF" ]

set outfile "temp_out_file"
#yes or no for all 
set hmr "no"   
set need_unitcell "no"
set need_glycan "no"

if {$need_glycan == "yes" } {
source /home/terabithia/bash/namd/glycan.tcl
topology /home/terabithia/bash/toppar/nag-bma-man.str  
topology /home/terabithia/bash/toppar/toppar_all36_carb_glycopeptide.str
topology /home/terabithia/bash/toppar/top_all36_carb.rtf 
#make sure to remove glycans whihc not bound to protein 
set gly_lst [parseglycan $pdbname]
set gly_lst [lreplace $gly_lst 0 0]
}

#Adding protein segments
foreach in_pdb ${pro_lst} seg ${pro_seg_lst} {
segment $seg { first none; last CTER; pdb ${in_pdb} }
coordpdb ${in_pdb} ${seg}
}
#Adding ligand segments
if { [llength $lig_lst ] != 0 }  {
foreach in_pdb ${lig_lst} seg ${lig_seg_lst} {
segment $seg { first none; last none; pdb ${in_pdb} }
coordpdb ${in_pdb} ${seg}
}
}
#Adding protein segments
if {  [llength $wat_lst ] != 0 } {
foreach in_pdb ${wat_lst} seg ${wat_seg_lst} {
segment $seg { first none; last none; pdb ${in_pdb} }
coordpdb ${in_pdb} ${seg}
}
}

guesscoord
writepdb temp.pdb
writepsf temp.psf 

#######
mol load psf temp.psf pdb temp.pdb
rm temp.psf 
rm temp.pdb 

foreach seg ${pro_seg_lst} {

##patches 
#Nterminal
set t_sel [atomselect top "protein and segname ${seg} "]

set resname_lst [ ${t_sel} get resname]
if { [lindex ${resname_lst} 0] == "GLY" } {
patch GLYP ${seg}:[lindex [${t_sel} get resid] 0]
} elseif { [lindex ${resname_lst} 0] == "PRO"} {
patch PROP ${seg}:[lindex [${t_sel} get resid] 0] 
} else {
patch NTER ${seg}:[lindex [${t_sel} get resid] 0]
}
}
${t_sel} delete
#disulfide if any
set t_sel [atomselect top "protein and name SG "]
if { [llength [$t_sel get index]] > 1 } {
set sslst [${t_sel} get index]
set ssdone [list ]
foreach ss $sslst  {
if {[lsearch -exact $ssdone "$ss"] < 0} { 
set a [atomselect top " index $ss" ]
set b [atomselect top "(index $sslst ) and exwithin 5.1 of index $ss"]
if { [$b get index ] == "" } {
continue
} elseif { [lsearch [lindex [$b getbonds ] 0]  "$ss" ] > 0  } {
#this section checks if the atom already bonds to selected index
continue 
} else {
patch DISU   [$a get segname ]:[$a get resid ] [$b get segname ]:[$b get resid ] 
lappend ssdone [$a get index] [$b get index]
}
}
}
}

### GLycan addition if needed
if {$need_glycan == "yes" } {
#this only works as long as link definition carries chains in order
#also only supprts linkers via C1 
foreach link  $gly_lst  {
if { [lindex $link  0] == "C1" } {
  if       { [lindex $link  4] == "ND2" } { 
    patch NGLA H[lindex $link 6]:[lindex $link  7] S[lindex $link   2]:[lindex $link  3]
  } elseif { [lindex $link  4] == "NE2"  } {
    patch QGLA H[lindex $link 6]:[lindex $link  7] S[lindex $link   2]:[lindex $link  3] 
  } elseif { [lindex $link  4] == "O1" } {
    patch 11aa S[lindex $link 6]:[lindex $link  7] S[lindex $link   2]:[lindex $link  3] 
  } elseif { [lindex $link  4] == "O2" } {
    patch 12aa S[lindex $link 6]:[lindex $link  7] S[lindex $link   2]:[lindex $link  3]
  } elseif { [lindex $link  4] == "O3" } {
    patch 13aa S[lindex $link 6]:[lindex $link  7] S[lindex $link   2]:[lindex $link  3]
  } elseif { [lindex $link  4] == "O4" } {
    patch 14aa S[lindex $link 6]:[lindex $link  7] S[lindex $link   2]:[lindex $link  3]
  } elseif { [lindex $link  4] == "O6" } {
    patch 16aa S[lindex $link 6]:[lindex $link  7] S[lindex $link   2]:[lindex $link  3]
  } else {
    puts "WARNING: patch not found"
  }
} elseif { [lindex $link  4] == "C1" } { 
  if       { [lindex $link  0] == "ND2" } { 
    patch NGLA H[lindex $link   2]:[lindex $link  3] S[lindex $link  6]:[lindex $link  7]
  } elseif { [lindex $link  0] == "NE2"  } {
    patch QGLA H[lindex $link   2]:[lindex $link  3] S[lindex $link 6]:[lindex $link  7] 
  } elseif { [lindex $link  0] == "O1" } {
    patch 11aa S[lindex $link   2]:[lindex $link  3] S[lindex $link 6]:[lindex $link  7] 
  } elseif { [lindex $link  0] == "O2" } {
    patch 12aa S[lindex $link   2]:[lindex $link  3] S[lindex $link 6]:[lindex $link  7]
  } elseif { [lindex $link  0] == "O3" } {
    patch 13aa S[lindex $link   2]:[lindex $link  3] S[lindex $link 6]:[lindex $link  7]
  } elseif { [lindex $link  0] == "O4" } {
    patch 14aa S[lindex $link   2]:[lindex $link  3] S[lindex $link 6]:[lindex $link  7]
  } elseif { [lindex $link  0] == "O6" } {
    patch 16aa S[lindex $link   2]:[lindex $link  3] S[lindex $link 6]:[lindex $link  7]
  } else {
    puts "WARNING: patch not found"
  }
}
}
}

### hydrogen mass repartition
if { $hmr == "yes" } {
hmassrepart dowater 0
}
regenerate angles dihedrals
guesscoord 
writepdb ${outfile}.pdb 
writepsf ${outfile}.psf

### biological unit operation
if { $need_unitcell == "yes" } {
mol delete top
mol load psf ${outfile}.psf pdb ${outfile}.pdb

source /home/terabithia/bash/namd/mono2poly.tcl 
set matrix [parsematrix ${pdbname}]
set sel [atomselect top all]
mono2poly -o test3 $sel $matrix


mol delete top

#merging three structures 
package require topotools 
# load to be merged molecules into VMD
set midlist {}

for {set i 0} {$i < [llength $matrix]} {incr i} {
set mol [mol new ${outfile}.psf waitfor all]
mol addfile test3.${i}.pdb
foreach seg [lsort -unique [[atomselect top all] get segname]] {
set tmp [atomselect top "segname ${seg}"]
$tmp set segname ${seg}${i}
}
lappend midlist $mol
}

# do the magic
set mol [::TopoTools::mergemols $midlist]
animate write psf ${outfile}.psf $mol
animate write pdb ${outfile}.pdb $mol
}

quit 
