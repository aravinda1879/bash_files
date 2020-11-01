## this code intended to connect glycans

proc parseglycan {orig_file} {
    set infile [open  $orig_file r]
    set gly_bonds 0
    set lineinfo($gly_bonds) "temp"
    while {[gets $infile line]>=0} {
	set title [lindex $line 0]
	if { $title == "LINK" } { 
	    incr gly_bonds 1
	    set lineelement [lrange $line 1 8]
	    set lineinfo($gly_bonds) $lineelement 
	}
    }
    set glyco_lst []
    foreach name [lsort -integer [array names lineinfo]] {
	lappend glyco_lst $lineinfo($name)
    }
    close $infile 
    #return [array get lineinfo]
    return $glyco_lst
}

	
