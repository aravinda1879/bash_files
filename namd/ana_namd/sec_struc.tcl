puts "loading secondary structure tcl"
proc sec_structure { mol out_file {sel1 "name CA" } } {
	set num_steps [molinfo $mol get numframes]
	set sel_1 [ atomselect top "$sel1" ]
	set outfile [ open $out_file w ]
	set lst_resid [ $sel_1 get resid ]
	set lst_segname [ $sel_1 get segname ]
	puts $outfile "# alpha H , 310_helix G , pi_helix I , strand E , Bridge B , Coil C , Turn_gamma T"
	set num_res [llength $lst_resid]
	puts $outfile "# numberofresidues $num_res"
	puts $outfile "# $lst_resid"
	puts $outfile "# $lst_segname"
	for {set i 0} {$i < $num_steps} {incr i} {
		animate goto $i
		display update ui
		mol ssrecalc top
		set lst_sec [ $sel_1 get structure ]
		puts $outfile "$i $lst_sec"
	}
	close $outfile
	puts "finish secondary structure analysis"
}
puts "Fnish loading sec_struc.tcl script"
