package require psfgen
#common var
#set pro "lys_r"
#set clength 10
#three tacticity options are ata=atactic, iso=isotactic, syn=syndiotactic
set tct "iso"
set topdir "/home/$env(USER)/Dropbox/diff_polymer/toppar"
set strdir "/home/$env(USER)/Dropbox/diff_polymer/str"
source polymer_builder.tcl
set pro "protein_input"
#set conju_site "1 13 33 97 116"
set init_dir "${strdir}/maleimide"
set init_nme "mal"

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
set out_file2 "${pro}_${tct}pCB2_linear_s5"

#topology $topdir/top_all36_prot.rtf
topology $topdir/top_all35_ethers-oh.rtf
topology $topdir/patch.inp
topology $topdir/top_all36_cgenff.rtf
#topology $topdir/toppar_all36_synthetic_polymer_patch.str
#topology $topdir/toppar_all36_synthetic_polymer.str

topology $init_dir/${init_nme}.str
#topology $mm_bb_dir/${mm_bb_nme}.str
topology $side_dir/$side_nm.str 
topology $side2_dir/$side2_nm.str 


#first chain
lassign { B C 50 5 {A1 A36 A79 A90 A169 A177 A202} } seg_bb seg_side clength branches int_seg_lst
lassign { P00349 P00350 P00343 P00342 MACB2 MA2AZ MASBR MARBR }  sr ss rs rr pside pside2 send rend


readpsf ${pro}.psf pdb ${pro}.pdb
foreach intseg $int_seg_lst {
	lassign { B C 200 5 } seg_bb seg_side clength branches 
	set copol_lst {}
	while {[llength $copol_lst] < $branches } {
		set rnd_num [random_bw 1 $clength]
		if {[lsearch -exact $copol_lst $rnd_num] == -1} {
			lappend copol_lst $rnd_num
		}
	}
	set copol_lst [lsort $copol_lst]
	puts "$copol_lst"
	set seg_bb ${intseg}$seg_bb
	set seg_side ${intseg}$seg_side
	set chiral_list [build_polymer_bb $clength $tct $seg_bb $seg_side $mm_bb_dir $mm_bb_nmes $mm_bb_nmer $side_dir $side_nm]
	build_polymer_side "homo" $clength $chiral_list $copol_lst $seg_bb $seg_side $side_dir $side_nm $side2_dir $side2_nm

	patch IACR $intseg:1 ${seg_bb}:1
	patch_mid $chiral_list $clength $seg_bb $seg_side $sr $ss $rs $rr 
	patch_end $chiral_list $seg_bb $clength $send $rend
	patch_side "homo" $clength $seg_bb $seg_side $pside $pside2 $copol_lst

	#for {set i 1} {$i <= [llength $copol_lst ]} {incr i} {
	#	segment ${intseg}A$i {pdb $init_dir/${init_nme}.pdb}
	#	patch AZ2I ${seg_side}:[lindex $copol_lst [expr $i-1]] ${intseg}A$i:1
	#} 
}
guesscoord
#regenerate resids
regenerate angles dihedrals

writepdb $out_file2.pdb
writepsf $out_file2.psf


###################################### renumbering section begins ##############
proc renum_files {} {
	set mol [mol new "${out_file}.psf" type psf waitfor all]
	mol addfile "${out_file}.pdb" type pdb waitfor all molid $mol

	set res_sel0 [atomselect top "segname A0"]
	$res_sel0 set resid 0
	for { set m 1 } { $m < [expr $clength +1] } { incr m } {
		set res_sel1 [atomselect top "segname ${seg_bb}$m"]
		$res_sel1 set resid [expr $m*2 - 1]
		set res_sel2 [atomselect top "segname ${seg_side}$m"]
		$res_sel2 set resid [expr $m*2]
		set res_sel3 [atomselect top "segname ${seg_side}$m ${seg_bb}$m A0"]
		$res_sel3 set segname "FREE"
	}
	set all [atomselect top all]
	$all writepdb ${out_file2}.pdb
	$all writepsf ${out_file2}.psf
}

quit







