proc allign {mol sel_allign { ref_allign "0" }} {
	set reference [atomselect $mol "$sel_allign" frame $ref_allign ]
	set compare [atomselect $mol "$sel_allign"]
	set all [atomselect $mol "all"]
	set num_steps [molinfo $mol get numframes]
	for {set frame 0} {$frame < $num_steps} {incr frame} {
		$compare frame $frame
		$all frame $frame
		set trans_mat [measure fit $compare $reference]
		$all move $trans_mat
	}
	puts "Alligning is done"
}
proc corr_map { mol selection f_name_o start_frame} {
	allign top "$selection"
	set num_steps [molinfo $mol get numframes]
	set selection [atomselect $mol "$selection"]
	set rlist [lsort -integer -unique -index 0 [$selection get {residue segname resid}]]
	#get the atom selection
	molinfo top set frame 0
	foreach res $rlist {
		set r [lindex $res 0]
		set sel($r) [atomselect 0 "residue $r"]
		#$sel($r) global
		#initialize cross corelation matrix
		foreach resprime $rlist {
			set rprime [lindex $resprime 0]
			if { $rprime > $r } { break }
			set ccor($r,$rprime) 0.0
		}
	}
	#initial com of each residue
	foreach res $rlist {
		molinfo top set frame [ expr $start_frame -1 ]
		set r [lindex $res 0]
		set comlast($r) [measure center $sel($r) weight mass]
	}
	for {set i $start_frame } {$i < $num_steps} {incr i} {
		molinfo top set frame $i
		foreach res $rlist {
			set r [lindex $res 0]
			#puts "working on frame $i"
			$sel($r) update
			#measuring the new COM
			set com($r) [measure center $sel($r) weight mass]
			set delta($r) [vecnorm [vecsub $com($r) $comlast($r)]]
			#computing the cross correlation
			foreach resprime $rlist {
				set rprime [lindex $resprime 0]
				if { $rprime > $r } { break }
				set ccor($r,$rprime) [expr $ccor($r,$rprime) + [vecdot $delta($r) $delta($rprime)]]
			}
			#updating the last com value
			set comlast($r) $com($r)
		}
	}
	#devide by the number of frames -1
	set norm [expr (1./($num_steps-1.0))]
	foreach res $rlist {
		set r [lindex $res 0]
		foreach resprime $rlist {
			set rprime [lindex $resprime 0]
			if { $rprime > $r } { break }
			set ccor($r,$rprime) [expr $norm * $ccor($r,$rprime)]
			#for plotting purposes, zero out negative entries above the diagonal and positive entries below
			if { $ccor($r,$rprime) < 0.0 } {
				set ccor($rprime,$r) $ccor($r,$rprime)
				set ccor($r,$rprime) 0.0
			} elseif { $r != $rprime } {
				set ccor($rprime,$r) 0.0
			}
		}
	}
	#printign the correlation data to a file
	set outfile [open $f_name_o w] 
	set rlast [lindex [lindex $rlist end] 0]
	foreach res $rlist {
		set r [lindex $res 0]
		foreach resprime $rlist {
			set rprime [lindex $resprime 0]
			if {  $rprime != $rlast } {
				puts -nonewline $outfile [format "%7.3f" $ccor($r,$rprime)]
			} else { 
				puts $outfile [format "%7.3f" $ccor($r,$rprime)]
			}
		}
	}
	flush $outfile
	close $outfile
	puts "Done making the matrix correlation file"
}
