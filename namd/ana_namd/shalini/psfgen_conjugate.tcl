package require psfgen
#common var
#set pro "lys_r"
#set clength 10
#three tacticity options are ata=atactic, iso=isotactic, syn=syndiotactic
set tct "iso"
set topdir "/home/$env(USER)/Dropbox/diff_polymer/toppar"
set strdir "/home/$env(USER)/Dropbox/diff_polymer/str"
source ../polymer_builder.tcl
set pro "protein_input"
#set conju_site "1 13 33 97 116"
set init_dir "${strdir}/maleimide"
set init_file "malfile"
set init_nme "malname"
set mm_bb_dir "${strdir}/peg"
set mm_bb_nmes "PEGM"
set mm_bb_nmer "PEGM"

#no need as polymer description taken from charmm
#set mm_bb_dir "${strdir}/peg"
#set mm_bb_nmes "peg"
#set mm_bb_nmer "ma_r_bb"
#set mm_x_dir "${strdir}/ma_bb_br"
#set mm_x_nme "ma_mol_br"
#set side_dir "${strdir}/cbma_n2"
#set side_nm "cb2"
#set side2_dir "${strdir}/azide_linker"
#set side2_nm "az_ln"

set out_file  "${pro}_pCBMA_linear"
set out_file2 "outconjufile"
set in_file "residueID_C_mod0.mut"
set infile [open $in_file r] 
set int_seg_lst [ gets $infile] 


topology $topdir/top_all36_prot.rtf
topology $topdir/top_all35_ethers-oh.rtf
topology $topdir/patch.inp
topology $topdir/top_all36_cgenff.rtf
#topology $topdir/toppar_all36_synthetic_polymer_patch.str
#topology $topdir/toppar_all36_synthetic_polymer.str

topology $init_dir/${init_file}.str
#topology $mm_bb_dir/${mm_bb_nme}.str
#topology $side_dir/$side_nm.str 
#topology $side2_dir/$side2_nm.str 


#first chain
lassign { B 24 no} seg_bb clength hmr
lassign {  HYD2 HYD2 }  send rend


readpsf ${pro}.psf pdb ${pro}.pdb
foreach intseg $int_seg_lst {
	lassign { 24 } clength 
	set sn [lindex [regexp -all -inline {(\d){1,3}} $intseg] 0]
	set rid [lindex [regexp -all -inline {(\d){1,3}$} $intseg] 0]
        puts "Working on $rid"
        segment  ${sn}$rid { residue 1 $init_nme}
        patch KPINIT $intseg ${sn}${rid}:1
	set seg_bb C${sn}${rid}
	puts "segment name for polymer in $seg_bb"
	#set chiral_list [build_polymer_bb $clength $tct $seg_bb $mm_bb_nmes $mm_bb_nmer ]
	#patch MALPEG ${sn}${rid}:1 $seg_bb:1
	#patch_end $chiral_list $seg_bb $clength $send $rend
}
guesscoord
### hydrogen mass repartition
if { $hmr == "yes" } {
hmassrepart dowater 0
}


#regenerate resids
regenerate angles dihedrals

writepdb $out_file2.pdb
writepsf $out_file2.psf

quit







