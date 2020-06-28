#available scripts are as follows
#sasa_cal mol f_name sel restrict
#center_of_mass 
#list_diff list1 list2  
#print_rmsd_through_time {mol f_name sel_1 sel_2}
#allign_pdb2_to_pdb1 { mol1 mol2 ou_file}
#distance { mol a_1 a_2 f_name} 
#improper_dihedral {mol f_name }
#dihedral_c2_c1 { mol start num_peg f_name}
#radial { mol sel1 sel2 r_max ou_file fst }
#contact {mol sel_1 sel_2 cutoff f_name} 
#contact_res_freq {mol in_file ou_file ou_file2}
#get_res_name {mol in_file ou_file}    NOT TESTED yet
#res_contact_timeline {mol in_file ou_file} 
#Rg {mol selection f_name}
#proc distribution { d_array_list {mol "top"} {f_name "na"} {num_bins "100"} {if_print "0"} args }
#incr_resnumber {mol out_pdb out_psf  }
#continue_resnumber {mol beg_num out_old_res_new_res_file out_pdb out_psf need_psf }
#bfactor {sel start end outfile} 
puts "vmd_proc.tcl was read"
#Prints the SASA of selection use -points pts if want to get picture then foreach pt $pts { draw point $pt } to get the drawing for frame
proc wrap { sel_wrap } { 
	package require pbctools
	pbc wrap -center com -centersel "$sel_wrap" -all -compound residue
}

proc images { ini_frame num_pdbs sel_1 { psf_name "caver.psf" } } {
	set num_frames [molinfo top get numframes]
	set num_steps [ expr $num_frames - $ini_frame ]
	set stp_sz [expr $num_steps / $num_pdbs  ]
	set sel1 [ atomselect top "$sel_1" ]
	for { set frame $ini_frame } { $frame < $num_frames } { incr frame $stp_sz  } {
		$sel1 frame $frame
		$sel1 update
		$sel1 writepdb [expr $frame - $ini_frame].pdb 
	}
	$sel1 writepsf $psf_name 
	puts "Done printing all the pdbs and the psf"		
}


proc allign_traj { mol_ref sel_ref { mol_comp "top"  } } {
	set reference [atomselect $mol_ref "$sel_ref" frame 0]
	set compare [atomselect $mol_comp "$sel_ref"]
	set move_all  [atomselect $mol_comp "all"]
	set num_steps [molinfo $mol_comp get numframes]
	for { set frame 0 } { $frame < $num_steps } { incr frame } {
		$compare frame $frame
		$move_all frame $frame
		set trans_mat [measure fit $compare $reference]
		$move_all move $trans_mat
	}
	puts "Allignment is done!"
}

proc shape_asp { mol out_file sel_1  } {
	set outfile [open $out_file w]
      puts $outfile "#frame Iz Iy Ix l1 l2  rel_shape_anisotropy aspectR_ZY aspectR_ZX"
	set num_steps [molinfo $mol get numframes]
	set sel1 [atomselect $mol "$sel_1"]
	for {set frame 0} {$frame < $num_steps} {incr frame} {
		$sel1 frame $frame
		set lis_out [measure inertia $sel1 moments eigenvals ]
		set l1 [ expr { [lindex [lindex $lis_out 3] 0] + [lindex [lindex $lis_out 3] 1] + [lindex [lindex $lis_out 3] 2] }  ]
		set l2 [ expr { [lindex [lindex $lis_out 3] 0] * [lindex [lindex $lis_out 3] 1] + [lindex [lindex $lis_out 3] 1] * [lindex [lindex $lis_out 3] 2] + [lindex [lindex $lis_out 3] 2] * [lindex [lindex $lis_out 3] 0]  } ]
		set sh_ani [ expr { 1 - ( 3 * ($l2/($l1*$l1)) )   }  ]
		set ar_ZY [ expr { [lindex [lindex $lis_out 3] 0]/[lindex [lindex $lis_out 3] 1] } ]
		set ar_ZX [ expr { [lindex [lindex $lis_out 3] 0]/[lindex [lindex $lis_out 3] 2] } ]
		puts $outfile "$frame [lindex [lindex $lis_out 3] 0] [lindex [lindex $lis_out 3] 1] [lindex [lindex $lis_out 3] 2] $l1 $l2 $sh_ani $ar_ZY $ar_ZX"
	}
	close $outfile
	puts "Shape analysis is done"
}

#Radial distribution calculation of selected residue list from patch_resinfo list
proc radial_patch_resinfo { mol in_file_1 post_fix  { out_file_1 "NA" } {fst "500" } { lst "-1"} } {
	set in_file1 [open $in_file_1]
	set list_line [split [read $in_file1] "\n"]
	set list_line [lsearch -all -inline -not  $list_line #* ]
	foreach line $list_line {
		set line_info [regexp -all -inline {\S+} $line ]
		puts "$line_info"
		radial top "residue [lindex $line_info 2] and resid [lindex $line_info 1]" "resname PEGM and oxygen" 15 "radial/resid_[lindex $line_info 1]_pegO_$post_fix.dat" $fst $lst "no" 
		radial top "residue [lindex $line_info 2] and resid [lindex $line_info 1]" "resname PEGM and carbon" 15 "radial/resid_[lindex $line_info 1]_pegC_$post_fix.dat" $fst $lst "no"
	}


}


# get resname with cutoff  in_file = resid vs time, in_file_2= contact file
proc patch_resinfo { mol in_file_1 in_file_2 out_file_1   { frame_load_time "10" }  { cutoff "25" } } {
	set in_file1 [open $in_file_1]
	set in_file2 [open $in_file_2]
	set filtered_resinfo {}
	set filtered_time {}
	set num_steps [ lindex [ gets $in_file2 ] 1 ]
	close $in_file2
	set del0 [ atomselect $mol "protein and name CA" ]
	set rlist [ $del0 get { residue segname resid } ]
	set rlast [lindex [ lindex $rlist end ] 0]
	set res_con_list [split [read $in_file1] "\n"]
	for { set res_id 0 } { $res_id <= $rlast } {incr res_id} {
              set line [split [lindex $res_con_list $res_id] " " ]
	      if { [lindex $line 1] > [expr double($cutoff)*1000/double($frame_load_time)] } {
                    puts "[lindex $line 1]   --> [expr double($cutoff)*1000/double($frame_load_time)] "
                      #since only doing for the protein
	              set del1 [atomselect $mol "resid [join [lindex $line 0 ]] and protein "]
                      set resinfo [ join [ lsort -integer -unique -index 0 [$del1 get {residue segname resid resname}] ] ]
                      lappend filtered_resinfo $resinfo
                      lappend filtered_time [list [lindex $line 1 ] [lindex $line 2 ]]
                      $del1 delete 
              }
	}
      puts "$filtered_resinfo"
	puts "[llength $filtered_resinfo] $rlast"
	set outfile1 [open $out_file_1 w]
	puts $outfile1 "#resid residue segname resname time(ns) normalized_time(persimulation)"
	for {set i 0} { $i < [llength $filtered_resinfo] } {incr i} {
		puts "[lindex $filtered_resinfo $i 1] [lindex $filtered_resinfo $i 2] [lindex $filtered_resinfo $i 0] [lindex $filtered_resinfo $i 3] [lindex $filtered_time $i 0] $frame_load_time [lindex $filtered_time $i 1]"
		puts $outfile1 "[lindex $filtered_resinfo $i 1] [lindex $filtered_resinfo $i 2] [lindex $filtered_resinfo $i 0] [lindex $filtered_resinfo $i 3] [expr double([lindex $filtered_time $i 0])/1000*double($frame_load_time)] [lindex $filtered_time $i 1]"
        } 
        close $outfile1
	puts "Done printing residue information and time to the file"
}
# measure angle between three selections
proc angle_3_com { mol sel_1 sel_2 sel_3 dum_sel1 dum_sel2 dum_sel3 f_name { sel_wrap "wrap_true"  } } {
	if { $sel_wrap == "wrap_true" } {
		wrap $sel_wrap 
	}
	puts "calculating angle between 3 selection com"
	set num_steps [molinfo $mol get numframes]
	set list_angle [list ]
	set outfile [open $f_name w]
      set sel_1 [atomselect top "$sel_1"]
      set dum_sel_1 [atomselect top "index $dum_sel1"]
      set sel_2 [atomselect top "$sel_2"]
      set dum_sel_2 [atomselect top "index $dum_sel2"]
      set sel_3 [atomselect top "$sel_3"]
      set dum_sel_3 [atomselect top "index $dum_sel3"]
	for {set i 0} {$i < $num_steps} {incr i} {
		molinfo top set frame $i
            $sel_1 update
            $sel_2 update
            $sel_3 update
            #election 1
            set com_coor_1 [ measure center $sel_1 weight mass ]
		$dum_sel_1 moveto $com_coor_1
		#selection 2
		set com_coor_2 [ measure center $sel_2 weight mass ]
		$dum_sel_2 moveto $com_coor_2
		#selection 3
		set com_coor_3 [ measure center $sel_3 weight mass ]
		$dum_sel_3 moveto $com_coor_3
		lappend list_angle [ measure angle [list $dum_sel1 $dum_sel2 $dum_sel3] frame $i]
		puts $outfile "$i [lindex $list_angle $i]"
	}
	close $outfile
	puts "angle of COMs calculation is done"
	return  $list_angle

}
#preferential interaction coefficient
proc pref_cof { mol sel_1 sel_2 f_name } {
}
proc water_shell { mol f_name sel_real { sel_dum "no" } {cutoff "10" } {wrap "yes" } {sel_3 "water and oxygen" } } {
      puts "calculating atoms in the shell"  
	set num_steps [molinfo $mol get numframes]
      if  { $sel_dum != "no" } {
              set sel_2 "$sel_dum"
      } else {
              set sel_2 "$sel_real"
      }
	set list_wat_cnt [list ]
	set outfile [open $f_name w]
	if { $wrap == "yes" } {
		package require pbctools
		pbc wrap -center com -centersel "$sel_real" -all -compound residue
	}
	for {set i 0} {$i < $num_steps} {incr i} {
              molinfo top set frame $i
              set sel_1 [atomselect top "$sel_real"]
              set com_coor [ measure center $sel_1 weight mass ]
              if  { $sel_dum != "no" } {
                      set dum_sel [atomselect top "$sel_dum"]
                      $dum_sel moveto $com_coor
              }
              set sel_selection [atomselect top "($sel_3) and ( pbwithin $cutoff of ($sel_2))"]
              set num_water [$sel_selection num]
              lappend list_wat_cnt $num_water 
              $sel_selection delete
              $sel_1 delete 
              puts $outfile "$i $num_water"
      }
      close $outfile
      return $list_wat_cnt
}
#following will measure the COM of the selection
proc center_of_mass { selection } {
        #puts "calculating the COM"
        set selection [ atomselect top "$selection" ]
        if {[$selection num] <= 0} {
                error "center_of_mass: needs a selection with atoms"
        }
        #set the center of mass to 0
        set com [veczero]
        set mass 0
        #[$selection get {x y z}] returns the coordinates {x y z}
        #[$selection get {mass}] returns the masses
        foreach coord [$selection get {x y z}] m [$selection get mass] {
                set mass [expr $mass + $m]
                set com [vecadd $com [vecscale $m $coord]]
        }
        if {$mass == 0} {
                error "center_of_measure bondmass: total mass is zero"
        }
        return [vecscale [expr 1.0/$mass] $com]
        $selection delete
}
proc sasa_cal {mol f_name sel restrict { wrap "no" } { center_sel "protein"   } } {
	#make sure to wrap when using for a selected region and not to wrap when doing to all
	set sel1 [atomselect top "$sel"]
	set sel2 [atomselect top "$restrict"]
	if { $wrap == "yes" } {
		package require pbctools
		pbc wrap -center com -centersel "$center_sel" -all -compound residue
	}
	set outfile [open $f_name w]
	set num_steps [molinfo $mol get numframes]
	set list_sasa [list ]
	for {set i 0} {$i < $num_steps} {incr i} {
		#$sel1 frame $i
		#$sel2 frame $i
		molinfo top set frame $i
		set sasa_val [measure sasa 1.4 $sel1 -restrict $sel2]
		puts $outfile "$i $sasa_val"
		lappend list_sasa $sasa_val
		#$sel1 delete
		#$sel2 delete
	}
	close $outfile
	return  $list_sasa
	puts "SASA calculation is done!"
}
#write to a file
proc write_file_list {list1 outfile } {
	set outfile [open $outfile w]
	set frames [llength $list1]
	for {set i 0} {$i < $frames} {incr i} {
		puts $outfile "$i [lindex $list1 $i]"
	}
	close $outfile
}
#difference of two lists
proc list_diff {list1 list2} {
	set outlist [list ]
	foreach i $list1 j $list2 {
		set c [expr ($i-$j)]
		lappend outlist $c
	}
	return $outlist
}
 
#Prints the RMSD of the protein atoms between each timestep sel1 - allign sel2 - rmsd of
proc print_rmsd_through_time { mol_comp sel_comp  mol_ref sel_ref f_name } {
        set reference [atomselect $mol_ref "$sel_ref" frame 0]
        set compare [atomselect $mol_comp "$sel_comp"]
        #set measure_rmsd_ref [atomselect $mol "$sel_2" frame 0]
        set move_compare [atomselect $mol_comp "all"]
        set num_steps [molinfo $mol_comp get numframes]
        set outfile [open $f_name w]
        for {set frame 0} {$frame < $num_steps} {incr frame} {
                $compare frame $frame
                $move_compare frame $frame
                set trans_mat [measure fit $compare $reference]
                $move_compare move $trans_mat
                set rmsd [measure rmsd $compare $reference]
                puts $outfile "$frame $rmsd"
        }
        close $outfile 
	puts "RMSD is done!"
}

#Best fit the 2nd PDB to 1st PDB
proc allign_pdb2_to_pdb1 { mol1 mol2 ou_file} {
        set reference [atomselect $mol1 "backbone"]
        set compare [atomselect $mol2 "backbone"]
        set trans_mat [measure fit $compare $reference]
        set all [atomselect $mol2 all]
        $all move $trans_mat
        $all writepdb $ou_file
}

#distance between two atoms
proc distance { mol a_1 a_2 f_name} {
        set outfile [open $f_name w]
	set list_distance [list ]
        set num_steps [molinfo $mol get numframes]
	set a1 [ [ atomselect top "$a_1 or $a_2" ] get {index}]
        for {set frame 0} {$frame < $num_steps} {incr frame} {
                #set d_1($frame) [measure bond [list $a_1 $a_2] frame $frame]
		lappend list_distance [measure bond $a1 frame $frame]
                #puts $outfile "$frame $d_1($frame)"
		puts $outfile "$frame [lindex $list_distance $frame] "
        }

        close $outfile
	#for {set frame 0} {$frame < $num_steps} {incr frame} {
	#	lappend list_distance [expr(d_1($frame))]
	#}
        puts "distance calculation is done"
        return  $list_distance
}

#distance between two coms
proc dis_com { mol sel_1 sel_2 f_name } {
	set sel1 [atomselect top "$sel_1"] 
	set sel2 [atomselect top "$sel_2"] 
	set nf [molinfo top get numframes] 
	set list_distance [list ]
	set outfile [open $f_name w]
	for {set i 0} {$i < $nf} {incr i} { 
		$sel1 frame $i
		$sel2 frame $i
		set com1 [measure center $sel1 weight mass]
		set com2 [measure center $sel2 weight mass]
		lappend list_distance [veclength [vecsub $com1 $com2]]
		puts $outfile "$i [lindex $list_distance $i]" 
	}
	close $outfile
	puts "distance of COMs calculation is done"
	return  $list_distance
}

#improper dihedral 
proc improper_dihedral {mol f_name } {
        set outfile [open $f_name w]
        set num [molinfo top get numframes]
        for { set xx 0 } { $xx <= $num } { incr xx } {
                set d [measure imprp {6 1 8 7} frame $xx ]
                set d_array($xx.r) $d
                puts $outfile "$xx $d"
        }
        close $outfile
}

#dihedral of peg pi= O-c2-c1-O, psi=c2-c1-O-c2, omga= c1-O-c2-c1.
#start is for starting index and num_peg is the number of peg
#j=1st c1
#num_peg=num_peg-3 to avoid calculating final peg (c3 order is diffrernt) and starts off 2nd residue as well (to avoid c0).
proc dihedral_c2_c1 { mol start num_peg f_name_prefix {num_bins "360"}} {
        set num_steps [molinfo $mol get numframes]
        set list_dihed_pi {}
        set list_dihed_psi {}
        set list_dihed_omega {}
        set num_peg [ expr ( $num_peg - 3 ) ]
        #omega dihedral cal (calculation done from the initiator)
        for { set i 0 } { $i < $num_peg } { incr i } {
                set j [expr ($start + (7* $i))]
                set k [expr ($j + 3)]
                set l [expr ($j + 4)]
                set m [expr ($j + 7)]
                puts "$j $k $l $m"
                set t_omega [measure dihed "$j $k $l $m" frame all ]
                lappend list_dihed_omega $t_omega
        }
        #pi dihedral cal (calculation done from the initiator)
        for { set i 0 } { $i < $num_peg } { incr i } {
                set j [expr ($start + 3 + (7* $i))] 
                set k [expr ($j + 1)]
                set l [expr ($j + 4)]
                set m [expr ($j + 7)]
		    #puts "$k $j $l $m"
                set t_pi [measure dihed "$j $k $l $m" frame all ]
                lappend list_dihed_pi $t_pi
        }
        #psi dihedral cal (calculation done from the initiator)
        for { set i 0 } { $i < $num_peg } { incr i } {
                set j [expr ($start + 4 + (7* $i))]
                set k [expr ($j + 3)]
                set l [expr ($j + 6)]
                set m [expr ($j + 7)]
                set t_psi [measure dihed "$j $k $l $m" frame all ]
                lappend list_dihed_psi $t_psi
        }
        #printing each set to a file
        set outfile1 [open "${f_name_prefix}_pi.dat" w]
        set outfile2 [open "${f_name_prefix}_psi.dat" w]
        set outfile3 [open "${f_name_prefix}_omega.dat" w]
        for {set i 0} { $i < $num_peg } {incr i} { puts $outfile1 "$i|[lindex $list_dihed_pi $i]"}
        for {set i 0} { $i < $num_peg } {incr i} { puts $outfile2 "$i|[lindex $list_dihed_psi $i]"}
        for {set i 0} { $i < $num_peg } {incr i} { puts $outfile3 "$i|[lindex $list_dihed_omega $i]"}
        close $outfile1
        close $outfile2
        close $outfile3
        puts "done calculating dihedral angles"
	puts "now clculating the distribution of dihedrals"
        set dis_pi [ distribution [join $list_dihed_pi] top "dis_${f_name_prefix}_pi.dat" $num_bins 1 ]
        set dis_psi [ distribution [join $list_dihed_psi] top "dis_${f_name_prefix}_psi.dat" $num_bins 1 ]
        set dis_omega [ distribution [join $list_dihed_omega] top "dis_${f_name_prefix}_omega.dat" $num_bins 1 ]
}

#break the array to individual lists and print
proc pop_list { in_list num_peg num_bins } {
        #puts "[lindex $in_list 0 ]  $num_peg $num_bins"
        set outfile [open ss w]
        #set list_pop_dihed [lrepeat $num_peg 9]
        set list_pop_dihed {}
        for { set i 0 } { $i < $num_peg  } { incr i } {
                #puts "$i"
                #puts " [lindex $list_pop_dihed 0]"
                set temp [distribution  [lindex $in_list $i ] top na $num_bins 0 -180 180]
                #puts $outfile "$temp"
                #lappend list_pop_dihed [ distribution  [lindex $in_list $i ] top na $num_bins 0 -180 180]
                lappend list_pop_dihed $temp
                unset temp
                #puts $outfile  "$list_pop_dihed"
                #if {$i==5} { close  $outfile
                #        et3}
        }
        return [list $list_pop_dihed ]
}

#radial distribution function
proc radial { mol sel1 sel2 r_max ou_file fst lst { wrap "no"} } {
	if {$wrap=="yes"} {
		wrap "protein"
	}
	set sel1 [atomselect $mol "$sel1"]
	set sel2 [atomselect $mol "$sel2"]
        set l_gor [measure gofr $sel1 $sel2 delta 0.1 rmax $r_max usepbc 1 selupdate 1 first $fst last $lst step 1]
        set r_l [lindex $l_gor 0]
        set gr_l [lindex $l_gor 1]
        set int_l [lindex $l_gor 2]
        set outfile [open $ou_file w]
        foreach j  $r_l k $gr_l l  $int_l {
                 puts $outfile "$j $k $l"
        }
        close $outfile 
}

# contacts 
# sel_1 should be the polymer and sel_2 should be th protein
proc contact {mol sel_1 sel_2 cutoff f_name ini_frame { wrap "no" }  { wrap_center "protein" } } {
        set num_frames [molinfo $mol get numframes]
	set num_steps [expr $num_frames - $ini_frame ]
        set sel [ atomselect top all ]
	if { $wrap=="yes" } {
		package require pbctools
		pbc wrap -center com -centersel "$wrap_center" -all -compound residue
	}
	#later on make this function write at the end
	set con_lst {}
        set sel1 [atomselect top "$sel_1"]
        set sel2 [atomselect top "$sel_2"]
        set outfile [open $f_name w]
        set del0 [atomselect top "protein and name CA"]
        set res_num [expr ([llength [split [ $del0 get {resname}] " " ]] + 1)]
        $del0 delete
        puts $outfile "number_of_steps $num_steps"
        puts $outfile "number_of_residues $res_num"
        for { set frame $ini_frame } { $frame < $num_frames } { incr frame } {
                $sel1 frame $frame
                $sel1 update
                $sel2 frame $frame
                $sel2 update
                set atomlist [ measure contacts $cutoff $sel1 $sel2 ]
                puts $outfile "[expr $frame - $ini_frame]|[lindex $atomlist 0]|[lindex $atomlist 1]"
                # $sel1 delete
                #  $sel2 delete
        }
        close $outfile
        puts "contacts printed!"
}
puts " read till contact"
# contact text file for processing.
# THIS WILL NOT WORK FOR PDBs with SAME RESID 
# three files will be printed   -ou_file1=contct vs time - ou_file2=contactvs residue -ou3 reduced residue contact time vs residue -ou4 contact_based_on_contituent
# -pol_ou_file1 perframe how many totla contacts and normalized contacts -pol_ou_file2 which resid is in contact with polymer
#
# To optimize this code remove all these if loops. and skip all intermediate if pairlen ==0 --> did this. But parsing command was not removed
proc contact_res_freq { mol in_file ou_file ou_file2 ou_file3 ou_file4 pol_ou_file1 pol_ou_file2 { of1 "1" }  { of2 "1" } { of3 "1" }  { of4 "1" } { pol_of1 "1" } { pol_of2 "1" } { pol_res_name "PEGM" } { pol_atm_name "O1"  }   }  {
        set in_file [open $in_file]
        set num_steps [ lindex [gets $in_file] 1]
        set res_num [ lindex [gets $in_file] 1]
        set del0 [atomselect top "protein and name CA"]
        set delp0 [atomselect top "resname $pol_res_name and name $pol_atm_name"]
        #you may wanna change if two chains with the same resid
        set resnum_lst [ $del0 get resid]
        set pol_resnum_lst [ $delp0 get resid]
	  set segname_lst [ $del0 get segname]
        #expr ([llength [split [ $del0 get {resname}] " " ]] + 1)
        #set res_num [expr ([llength [split [ $del0 get {resname}] " " ]] + 1)]
        #$del0 delete
        #for BSA i am addding one since resid starts from 1. need to change for other proteins
        #set res_num [expr ( $res_num + 1) ]
        #for {set i 0} { $i < $res_num } {incr i} {set res_freq($i) 0}
	  #for {set i 0} { $i < $res_num } {incr i} {set res_time($i) 0}
	  foreach i $resnum_lst {set res_freq($i) 0 }
	  foreach i $resnum_lst {set res_time($i) 0 }
        foreach i $resnum_lst {set res_time_norm($i) 0 }
        foreach i $pol_resnum_lst {set pol_res_freq($i) 0 }
        #foreach i $pol_resnum_lst {set pol_res_freq_norm($i) 0 }
        foreach i $pol_resnum_lst {set pol_res_time($i) 0 }
        foreach i $pol_resnum_lst {set pol_res_time_norm($i) 0 }
	  for {set i 0} { $i < $num_steps } {incr i} {set total_contact_pfrm($i) 0}
        for {set i 0} { $i < $num_steps } {incr i} {set total_contact_pfrm_pol($i) 0}
        for {set i 0} { $i < $num_steps } {incr i} {set total_contact_pfrm_pol_norm($i) 0}
        set contact_side {}
        set contact_bak {} 
        set common_contact_sidebak {}
        puts "reading the input file"
        set con_list [split [read $in_file] "\n"]
        for { set t_stp 0 } { $t_stp < $num_steps } {incr t_stp} {
                set t_con [split [lindex $con_list $t_stp] "|" ]
		    #puts "finishing time step [lindex $t_con 0]"
		    set pol_lst [split [lindex $t_con 1] " " ]
                set pro_lst [split [lindex $t_con 2] " " ]
                #puts "number of contacts in protein [llength $pro_lst]"
                set pair_len [llength $pro_lst]
                if { $pair_len != 0 } {
                        #puts "making contct vs residue"
                        foreach pro_1 $pro_lst {
                                set del1 [atomselect top "index $pro_1"]
                                set t2 [ $del1 get resid ]
                                set res_freq($t2) [expr ( $res_freq($t2) + 1 ) ]
	                        $del1 delete
                        }
                        #puts "making polymer contct vs residue"
                        foreach pol_1 $pol_lst {
                                set del1 [atomselect top "index $pol_1"]
                                set t2 [ $del1 get resid ]
                                set pol_res_freq($t2) [expr ( $pol_res_freq($t2) + 1 ) ]
                                $del1 delete
                        }

                        set total_contact_pfrm_pol($t_stp) $pair_len
                        #puts "making polymer contcts per frame vs time"
                        set del2 [atomselect top "index $pol_lst"]
                        set t2 [ $del2 get resid ]
                        set unique_pol_lst [lsort -unique $t2]
                        set pol_len_unique [llength $unique_pol_lst]
                        set total_contact_pfrm_pol_norm($t_stp) $pol_len_unique
                        $del2 delete
                }
                #puts "making contcts per frame vs time"
                set total_contact_pfrm($t_stp) $pair_len
                #removing duplicates to count time
                set unique_pro_lst [lsort -unique $pro_lst]
                #making the side chain selection and backbone selection and remove duplicates
                #puts "making contct of residue based on constituent  vs time"
                if { $unique_pro_lst != {} } {
                        #puts "making contact time  vs residue"
                        set del1 [atomselect top "index $unique_pro_lst"]
                        set t2 [lsort -unique [$del1 get resid ] ]
                        $del1 delete
                        foreach t_rid $t2 {
                                #to speed up you can normalize outside the loop
                                set res_time($t_rid) [expr ( $res_time($t_rid) + 1 ) ]
                                set res_time_norm($t_rid) [expr ( double($res_time($t_rid)) / $num_steps ) ]
                        }
                        set del_sidechain [ atomselect top "index $unique_pro_lst and sidechain" ]
                        set tmp_lst_sidechain  [ lsort -unique [$del_sidechain get {resid}] ]
                        set del_backbone  [ atomselect top "index $unique_pro_lst and backbone" ]
                        set tmp_lst_backbone [lsort -unique [$del_backbone get {resid} ] ]
                        $del_sidechain delete
                        $del_backbone delete
                } else {
                        set tmp_lst_sidechain {}
                        set tmp_lst_backbone {}
                }
                if { $tmp_lst_sidechain != {} && $tmp_lst_backbone != {} } {
                        set del_sidebak [ atomselect top "resid $tmp_lst_sidechain and resid $tmp_lst_backbone" ]
                        set tmp_lst_sidebak [ lsort -unique [$del_sidebak get {resid} ] ]
                        $del_sidebak delete
                        lappend common_contact_sidebak $tmp_lst_sidebak
                        lappend contact_side $tmp_lst_sidechain
                        lappend contact_bak  $tmp_lst_backbone
                } else {
                        lappend common_contact_sidebak -1
                        if {$tmp_lst_sidechain == {} } {
                                lappend contact_side -1
                        } else {
                                lappend contact_side $tmp_lst_sidechain
                        }
                        if {$tmp_lst_backbone  == {} } { 
                                lappend contact_bak -1 
                        } else {
                                lappend contact_bak $tmp_lst_backbone
                        }
                }
				#for { set k 0 } { $k < [llength $] } { incr k } {
				#	set pro_2 [lindex $unique_pro_lst $k]
				#	set del1 [atomselect top "index $pro_1"]
				#	#removing identical resids
				#	set t2 [lsort -unique [$del1 get resid ] ]
				#	set res_time($t2) [expr ( $res_time($t2) + 1 ) ]
				#	set t1 $t2
				#	$del1 delete}                  
        }
        puts "finish loading everything to the memory"
        set outfile2 [open $ou_file2 w]
        for {set i 0} { $i < $num_steps } {incr i} {puts $outfile2 "$i $total_contact_pfrm($i)"}
        close $outfile2

        set outfile [open $ou_file w]
        foreach resi $resnum_lst { puts $outfile "$resi $res_freq($resi)"}
        close $outfile

        set outfile3 [open $ou_file3 w] 
        #for {set i 0} { $i < $res_num } {incr i} {puts $outfile3 "$i $res_time($i)"}
        #edited the following to add normalize time --> 04/24 normalized time is seems to be incorrect
        foreach resi $resnum_lst { puts $outfile3 "$resi $res_time($resi) $res_time_norm($resi)"}
        close $outfile3

        set outfile4 [open $ou_file4 w]
        puts $outfile4 "#time step| contact_side_chain | contact_bak_bone | common_contact_sidechain_and_backbone"
        for {set i 0} { $i < $num_steps } {incr i} {puts $outfile4 "$i|[lindex $contact_side $i]|[lindex $contact_bak $i]|[lindex $common_contact_sidebak $i]"}
        close $outfile4

        set outfile2 [open $pol_ou_file2 w]
        foreach resi $pol_resnum_lst { puts $outfile2 "$resi $pol_res_freq($resi)"}
        close $outfile2

        set outfile1 [open $pol_ou_file1 w]
        for {set i 0} { $i < $num_steps } {incr i} {puts $outfile1 "$i $total_contact_pfrm_pol($i) $total_contact_pfrm_pol_norm($i)"}
        close $outfile1
        #
        puts "[llength $contact_side] [llength $contact_bak] [llength  $common_contact_sidebak] "
        puts "contact frequency done! change resnumberfor nun BSA!!!"
}
#contact restype identification
#infile1- resit vs time infile2- original contact file
puts "loading restype procedure"
proc restype_contact { mol { outfile "contact_restype.dat" } {infile1 "contact.dat" } { infile2 "contact_resid_type_vs_time.dat" } { cutoff "0.25"  } } {
	set per_lst {}
	set cut_lst {}
	set incon [open $infile1]
        set indat [open $infile2]
	set outfile [open $outfile w]
        set num_steps [ lindex [gets $incon] 1]
        set res_num [ lindex [gets $incon] 1]
        #read values put them to an array. sort them. grap the value and its resname. and characterize
	set res_time_lst [split [read $indat] "\n"]
	#puts "$res_time_lst"
	foreach i $res_time_lst {
		set temp [split $i " "]
		#puts "$temp"
		lappend per_lst [ list [ lindex $temp 0] [ lindex $temp 2]]
	}
	#puts "$per_lst"
	set per_lst [lsort -index 1 $per_lst ]
	foreach i $per_lst { 
		if { [lindex $i 1] > $cutoff } {
			#check this line if it is not a protein
			set sel [concat [lindex $i 0]]
			set del0 [atomselect top "resid $sel and protein"]
			lappend i [lsort -unique [$del0 get resname]]
			lappend cut_lst $i 
		}
	}
	set cut_lst [lsort -decreasing -index 1 $cut_lst]
	foreach i $cut_lst {
		puts $outfile "[lindex $i 0] [lindex $i 1] [lindex $i 2]"
	}
}




#contact patch recognition
#to run this you need to have the reduced contact timeline file 
#infile1  original contact.dat file
#infile2  residue vs contact count  file 
#infile3  reduced timeline file python processed #outfile1 - 2d array output with patch id
proc contact_patch {mol infile1 infile2 infile3 outfile1 cutoff} {
        set infile1 [open $infile1]
        set infile2 [open $infile2]
        set infile3 [open $infile3]
        set num_frames [ lindex [gets $infile1] 1] 
        set num_res [ lindex [gets $infile1] 1]
        set sel_res_name [atomselect top "protein and name CA"]
        set patch_dis [lrepeat $res_num [lrepeat $numframes 0] ]
        set patch_dis_history [lrepeat $res_num {} ]
        set resid_lst [lrepeat $res_num 0]
        set resid_lst_cutoff [list {}]
        set patch_id 1
        close $infile1
	$sel_res_name delete
        #get contacts/time per each residue to a list tagging index to resid 
        for {set i 0} {$i < $num_res} {incr i} {
		gets $infile2 line2
                set resid [lindex $line2 0]
                set contact_res_freq [lindex $line2 1] 
                lset resid_lst $resid $contact_res_freq
        }
        close $infile2 
        #select residue above cutoff
        for {set i 0} {$i < $num_res} {incr i} {
                if { [lindex $resid_lst $i] > $cutoff } {
                        lappend resid_lst_cutoff [lindex $resid_lst $i]
                }
        }
        #taking resids in one time step
        set temp 0
        set list_temp {}
        for {set i 0} {$i < $num_frames} {incr i} {
                while "1==1" {
                        gets $infile3 line3
                        if {$temp != [lindex $line3 0 ]} break
                        set temp_2 [lsearch $resid_lst_cutoff [lindex $line3 1]]
                        if {$temp_2 != -1} {
                                lappend list_temp [lindex $line3 1]
                        }
                }
                #checking neighbors in resid indexes
                foreach resid $list_temp {
                        set sel_1 [atomselect top "protein and resid $temp_2 and pbwithin 7 of resid $resid "]
                        set temp_patch [lsort -unique [$sel_1 get {resid}]]
                        #check if any of them has a patch ID
			$sel_1 delete
                        if {$i==0}{
                                foreach resid_2 $temp_patch {
                                        #assign the patch number
                                        lset patch_dis $resid_2 $i $patch_id
                                }
                                set patch_id [expr {$patch_id +1}]
                        } else {
                                foreach resid_2 $temp_patch {
                                        #1st go through everything and get the history
                                        if {[lindex $patch_dis_history $resid_2] == {}}{
                                                lset patch_dis $resid_2 $i $patch_id 
                                                # increase patch number by 1 at the last resid
                                                if {$resid_2 == [lindex $temp_patch end} {
                                                        set patch_id [expr {$patch_id +1}]
                                                }
                                        } else {
                                                lset patch_dis $resid_2 $i [lindex $patch_dis_history $resid_2 end]
                                        }
                                }
                        }

                }
                unset list_temp
                set list_temp {}
                if {$line != -1} {
                        lappend list_temp [lindex $line3 1]
                }
        }
	set outfile [open $outfile]
        # write the out put patch name and all the resids 
	for { set i 0} {$i < $num_res } {incr $i } {
		puts $outfile "$i [lindex $patch_dis_history $i]"
        }
}
puts "contact patch loaded"
#contacts over the time res id t ores name 
proc get_res_name {mol in_file ou_file} {
        set in_file [open $in_file r]
        set outfile [open $ou_file w]
        set con_list [split [read $in_file] "\n"]
        set num_steps [llength $con_list ]
        foreach line $con_list {
                set l1 [split $line " "]
                set del0 [atomselect $mol "resid [lindex $l1 0]"]
                set res_name [ $del0 get resname]
                puts "res name $res_name"
                $del0 delete 
                puts $outfile "$res_name [lindex $l1 1]"
        }
        close $outfile
        puts "resname vs frequency printed"
}

#contact timeline  for each residue ou_file = contact residue vs time
proc res_contact_timeline {mol in_file out_file_1 out_file_2 } {
        set in_file [open $in_file r]
        set num_steps [ lindex [gets $in_file] 1]
        set lst_contact {}
        set lst_reduce_contact {}
	set lst_unique_reduce_contact {}
        set num_res [ lindex [gets $in_file] 1]
        set con_list [split [read $in_file] "\n"]
        for { set t_stp 0 } { $t_stp < $num_steps } {incr t_stp} {
                set t1 -1
                set t_con [split [lindex $con_list $t_stp] "|"]
                set pro_lst [split [lindex $t_con 2] " " ]
                #puts "[llength $pro_lst]"
                set tmp_lst_reduce_contact [ lsort -unique $pro_lst ]
                if {$tmp_lst_reduce_contact  != {} } {
                        set del_resid [atomselect top "index $tmp_lst_reduce_contact"] 
                        set tmp_lst_reduce_contact_resid [$del_resid get resid]
			set unique_tmp_lst_reduce_contact_resid [ lsort -unique $tmp_lst_reduce_contact_resid ]
			$del_resid delete
                        lappend lst_reduce_contact $tmp_lst_reduce_contact_resid 
			lappend lst_unique_reduce_contact $unique_tmp_lst_reduce_contact_resid 
                } else {
                        lappend lst_reduce_contact -1 
			lappend lst_unique_reduce_contact -1
                }
                #set pair_len [llength $pro_lst]
                #for { set i 0} { $i < $pair_len } {incr i} {
                #        set pro_1 [lindex $pro_lst $i]
                #        set del1 [atomselect top "index $pro_1"]
                #        set t2 [ $del1 get resid ]
                #        puts $outfile "$t_stp $t2"
                #        $del1 delete
                #}
        }
        set outfile1 [open $out_file_1 w]
	set outfile2 [open $out_file_2 w]
        for {set i 0} { $i < $num_steps } {incr i} {puts $outfile1 "$i|[lindex $lst_reduce_contact $i]"}
	close $outfile1
	for {set i 0} { $i < $num_steps } {incr i} {puts $outfile2 "$i|[lindex $lst_unique_reduce_contact $i]"}
	close $outfile2
        puts "time line of contact of residues done"        
}

#radius of gyration
puts "Rg function loaded"
proc Rg {mol selection f_name} {
        set sel [ atomselect top "$selection" ]
        set outfile [open $f_name w]
	set list_rg [list ]
        set num_steps [molinfo $mol get numframes]
        for {set frame 0} {$frame < $num_steps} {incr frame} {
                $sel frame $frame
                #set d_1($frame) [measure rgyr $sel ]
		lappend list_rg [measure rgyr $sel ] 
                #puts $outfile "$frame $d_1($frame)"
		puts $outfile "$frame [lindex $list_rg $frame]"
	}
        close $outfile
        puts "Rg measured!"
        return $list_rg
}
puts "Distribution function loaded"
#distribution
proc distribution { d_array_list {mol "top"} {f_name "na"} {num_bins "100"} {if_print "0"} args } {
        #args are for dihedral like populational analysis
        puts "caluclating normalized distribution"
        for {set i 0} { $i < [llength $d_array_list]} {incr i} {
                #puts "$i"
                set t [lindex $d_array_list $i]
                set d_array($i) $t
        }
        set num [molinfo $mol get numframes]
        if {[string length $args] == 0} {
                set d_min [expr $d_array(0)]
                set d_max [expr $d_array(0)]
        } else {
		puts "args detected. Using defined min max in args"
                set d_min [lindex $args 0]
                set d_max [lindex $args 1] 
        }
        for {set x 0} {$x < $num} {incr x} {
                set d_temp [expr $d_array($x)]
                #puts "44"
                if {$d_temp < $d_min} {set d_min $d_temp}
                if {$d_temp > $d_max} {set d_max $d_temp}
        }
        set N_d $num_bins
        set dr [expr ($d_max - $d_min) /($N_d - 1)]
        for {set k 0} {$k < $N_d} {incr k} {
                set distribution($k) 0
        }
        for {set i 0} {$i < $num} {incr i} {
                set k [expr int(($d_array($i) - $d_min) / $dr)]
                incr distribution($k)
        }
        set t_area 0
        for {set i 0} {$i < $N_d} {incr i} {
                set t_area [expr ($t_area + (($distribution($i)+0.0) * $dr) )]
        }
        for {set i 0} {$i < $N_d} {incr i} { 
                set distribution($i) [ expr ( ($distribution($i) + 0.0) / ($t_area + 0.0 ))]
        }
        #parray distribution
        if {$if_print == 1} {
                set outfile [open $f_name w]
                for {set k 0} {$k < $N_d} {incr k} {
                        puts $outfile "[expr $d_min + $k * $dr] $distribution($k)"
                }
                close $outfile
        } else {
                set element_size [expr ($N_d)]
                set x_y_val {}
                set x_val {}
                set y_val {}
                for {set k 0} {$k < $N_d} {incr k} {
                        lappend x_val [expr ($d_min + $k * $dr)]
                        lappend y_val $distribution($k)
                }
		lappend x_y_val $x_val
		lappend x_y_val $y_val
		return [list $x_y_val]
        }
}
#renumber resid's
proc incr_resnumber {mol out_pdb out_psf  } {
#        temp_resnum=$start_num
        set sel1 [atomselect $mol all]
        set num_atom [$sel1 get num]
        $sel1 delete
        for {set i 0} {$i < num_atom} {incr i} {
                set sel2 [atomselect $mol "index $i"]
                set now_resid [$sel1 get resid]
                set new_resid [ incr( now_resid )]
                $sel2 set resid $temp_resnum
                $sel2 delete
        }
        set sel1 [atomselect $mol all]
        $sel1 writepdb $out_pdb 
        $sel1 writepsf $out_psf
}

#Begin from a resnumber and keep increasing till end
proc continue_resnumber {mol beg_num out_old_res_new_res_file out_pdb out_psf need_psf } {
        set sel1 [atomselect $mol all]
        set num_atom [$sel1 num]
        $sel1 delete
        set outfile [open $out_old_res_new_res_file w]
        for {set i 0} {$i < $num_atom} {incr i} {
                set sel2 [atomselect $mol "index $i"]
                set cur_resname [$sel2 get resname ] 
                set cur_resid [$sel2 get resid]
                if { $i == 0 } {
                        set t_cur_resid $cur_resid
                        set new_resid $beg_num
                        set t_cur_resname $cur_resname
                        $sel2 set resid $new_resid
#                        puts $outfile "1"
                } elseif { $cur_resid == $t_cur_resid && $cur_resname == $t_cur_resname} {
                        $sel2 set resid $new_resid
#                        puts $outfile "2"
                } elseif { $cur_resid != $t_cur_resid || $cur_resname != $t_cur_resname} {
                        set new_resid [ incr new_resid ]
#                        puts "$new_resid $new_resid"
                        set t_cur_resid $cur_resid
                        set t_cur_resname $cur_resname
                        $sel2 set resid $new_resid
#                        puts $outfile "3"
                }
                $sel2 delete
                puts $outfile " $cur_resid $cur_resname --> $new_resid $cur_resname "
        }
        set sel1 [atomselect $mol all]
        $sel1 writepdb $out_pdb 
        if { $need_psf == "yes" } {
                $sel1 writepsf $out_psf
        }
}     

#### things taken from others
# Proceedure to generate BFACTORs from a trajectory within VMD
# VERSION 1.0
#
# All selected frames are superimposed on the reference frame (frame 0).
# The coords of the selected atoms in frame 0 are 
# set to the average atomic positions prior to writing
# PDB file. The B column of the PDB file is set to the calculated
# isotropic B-factor.
# 
# By Aaron Oakley 
# Research School of Chemistry
# Australian National University
# Email: oakley@rsc.anu.edu.au
# 
# Usage:
#     sel = atoms used for calculation e.g. "segname A and noh"
#   start = number of first frame for calculation
#     end = number of last frame for calculation
# outfile = pdb file containing average x,y,z coords
proc bfactor {sel start end outfile} {
set reference [atomselect top  "$sel" frame 0]
set compare [atomselect top  "$sel"]
set all [atomselect top all]
set atindex [[atomselect top "$sel"] get index] 
set pi 3.14159265
set numframes [expr $end - $start + 1]
# NB: Frames 10 to 20 has 11 frames, but 20 - 10 = 10!
# The following variables will contain the mean coords x,y,z,
# B-factor:
foreach r $atindex {
        set px($r) 0
        set py($r) 0
        set pz($r) 0
        set U($r) 0
        set B($r) 0
}
# loop over frames in the trajectory
# to calculate sum of x,y,z positions for each atom.
puts "Aligning selected frames to frame 0."
puts "Calculating mean positions of selected atoms $sel ..."
for {set frame $start} {$frame <= $end} {incr frame} {
	puts -nonewline "\rFrame: $frame"
        flush stdout
	# get the correct frame
	$compare frame $frame
	# compute the transformation
	set trans_mat [measure fit $compare $reference]
	# do the alignment
        set all_current [atomselect top all frame $frame]
	$all_current  move $trans_mat
        $all_current delete
	# loop through all atoms
        set getframe [atomselect top "index $atindex" frame $frame]
        set veclist [$getframe get {x y z}]
	foreach r $atindex vec $veclist {
                 set ix [lindex $vec 0]
                 set iy [lindex $vec 1]
                 set iz [lindex $vec 2] 
		set px($r) [expr $px($r) +  $ix ]
		set py($r) [expr $py($r) +  $iy ]
		set pz($r) [expr $pz($r) +  $iz ]
	}
        $getframe delete
}
puts ""
puts "...Done!"

# Now divide by $numframes to give the average coordinate for each atom
foreach r $atindex {
        set px($r) [expr $px($r) / $numframes]
        set py($r) [expr $py($r) / $numframes]
        set pz($r) [expr $pz($r) / $numframes]
}
# Now calculate bfactors for each atom:
puts "Calculating bfactors..."
set getframe [atomselect top "index $atindex"]
for {set frame $start} {$frame <= $end} {incr frame} {
        #loop through all atoms
	puts -nonewline "\rFrame: $frame"
        flush stdout
        $getframe frame $frame
        set veclist [$getframe get {x y z}]
        foreach r $atindex vec $veclist {
                set ix [lindex $vec 0]
                set iy [lindex $vec 1]
                set iz [lindex $vec 2]
                set dx [expr $ix - $px($r)]
                set dy [expr $iy - $py($r)]
                set dz [expr $iz - $pz($r)]
                set Uxx [expr $dx * $dx]
                set Uyy [expr $dy * $dy]
		set Uzz [expr $dz * $dz]
                set U($r) [expr $U($r) + $Uxx + $Uyy + $Uzz]
        }
}
$getframe delete
# Divide by $numframes to give average:
foreach r $atindex {
	set U($r) [expr $U($r) / $numframes]
}
# Conversion for B = 8/3 Pi**2 <Uxx + Uyy + Uzz>.
foreach r $atindex {
        set B($r)   [expr 8.0 / 3 * $pi * $pi * $U($r)]
}
puts ""
puts "...Done!"
# Set coordinates in frame 0 to "average" positions.
# Set beta to calculated B-factor.
foreach r $atindex {
        set getindex [atomselect top "index $r" frame 0]
        $getindex set x  $px($r)
        $getindex set y  $py($r)
        $getindex set z  $pz($r)
        $getindex set beta $B($r)
        $getindex delete
}
# Write pdb file with ANISOU records:
puts "Writing pdb file $outfile ..."
$reference writepdb $outfile
puts "...Done!"
}

