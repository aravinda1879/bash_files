proc build_polymer_bb {clength tct seg_bb resname_s resname_r  } {
	set chiral_list [list ]
	if { ${tct} == "syn" } {
	#this section is for syndiotactic 
		puts "tacticity of the polymer is syndio tactic"
		segment ${seg_bb}  {
		        first none		
			for { set m 1 } { $m < [expr $clength +1] } { incr m } {
				if { [expr $m % 2] == 0 } {
					residue $m $resname_s
					lappend chiral_list s   
				} else {
					#make sure the patch is correct and the next residue topology is good
					residue $m $resname_r
				        lappend chiral_list r
				}
			}
			last none
		}
	} elseif { ${tct} == "ata" } {
	#this section is for atactic 
		puts "tacticity of the polymer is atactic and polymer chain is ${clength}-mer"
		segment ${seg_bb}  {
		        first none
			for { set m 1 } { $m < [expr $clength +1] } { incr m } {
				set ran_num [expr (rand())]
				if { $ran_num > 0.5 } {
				        residue $m $resname_s 
				        lappend chiral_list s
				}  else {
				        residue $m $resname_r 
				        lappend chiral_list r
				}
			} 
			last none
		}
	} else {
	#this section is for isotactic 
		puts "tacticity of the polymer is isotactic with S confo"
		segment ${seg_bb}  {
		        first none
			for { set m 1 } { $m < [expr $clength +1] } { incr m } {
				residue $m $resname_s
				lappend chiral_list s
			}
			last none
		} 
	}
        puts "done build_polymer_bb"
	return $chiral_list
}
proc build_polymer_side { clength chiral_list seg_bb seg_side side_nm {type1 "homo"} { side2_nm "NA" } {copol_lst "NA" }  } {
		if {$type1 == "homo"} {
			segment ${seg_side} {
			        first none
				for { set m 1 } { $m < [expr $clength + 1] } { incr m } {
					#patch was changed to add new charges
					residue $m $side_nm
				}
				last none
			}
		} else {
			segment ${seg_side} {
			        first none
				puts "running the co_polymer section"
				for { set m 1 } { $m < [expr $clength + 1] } { incr m } {
					#patch was changed to add new charges
					if {[lsearch -exact $copol_lst $m] == -1} {
						residue $m $side_nm
					} else {
						residue $m $side2_nm
					}
				}
				last none
			}
		}
}


proc patch_bb { chiral_list clength seg_bb sr ss rs rr} {
	puts "$sr $ss $rs $rr"
	for { set m 1 } { $m < $clength } { incr m } {
		if { [lindex $chiral_list [expr $m-1] ] == "s" && [lindex $chiral_list [expr $m ] ] == "r" } {
		        #conneting the MMAS+MAMR
			patch $sr ${seg_bb}:$m ${seg_bb}:[expr $m+1]    
		} elseif { [lindex $chiral_list [expr $m-1]] == "s" && [lindex $chiral_list [expr $m ] ] == "s" } {
			#conneting the MMAS+MAMS
			patch $ss ${seg_bb}:$m ${seg_bb}:[expr $m+1]
		} elseif { [lindex $chiral_list [expr $m-1]] == "r" && [lindex $chiral_list [expr $m] ] == "s" } {
			#conneting the MMAR+MAMS
			patch $rs ${seg_bb}:$m ${seg_bb}:[expr $m+1]
		} else {
		        #conneting the MMAR+MAMR
		        patch $rr ${seg_bb}:$m ${seg_bb}:[expr $m+1]
		}
	}
}
 
proc patch_side {  clength seg_bb seg_side pside {type1 "homo"} {pside2 "na" } {copol_lst "na"}  } {
	if {$type1 == "homo"} {
		for { set m 1 } { $m < [expr $clength + 1] } { incr m } {
			#patch was changed to add new charges
			patch $pside  ${seg_bb}:$m ${seg_side}:$m
		}
	} else {
		for { set m 1 } { $m < [expr $clength + 1] } { incr m } {
			#patch was changed to add new charges
			if {[lsearch -exact $copol_lst $m] == -1} {
				patch $pside  ${seg_bb}:$m ${seg_side}:$m
			} else {
				patch $pside2  ${seg_bb}:$m ${seg_side}:$m
			}
		}
	}
}
 
proc patch_end { chiral_list seg_bb m send rend} {        
	if { [lindex $chiral_list end] == "s" } {
	 	patch $send ${seg_bb}:$m
	} else {
		patch $rend ${seg_bb}:$m
	}
}
 
proc random_bw {m M} {return [expr $m+round(rand()*($M-$m))]}

puts "polymer builder loaded"

