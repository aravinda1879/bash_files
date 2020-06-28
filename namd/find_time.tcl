if {1} { 
# procedure to get the first time step for the new simulation 
# from the old simulation whether it be a completed sim or one 
# to be restarte}
proc get_first_ts { xscfile } { 
set fd [open $xscfile r] 
gets $fd 
gets $fd 
gets $fd line 
set ts [lindex $line 0] 
close $fd 
return $ts 
}
if [file exists $inputname.xsc] { 
set firsttime [get_first_ts $inputname.xsc]
firsttimestep $firsttime 
} else {
set firsttime [get_first_ts $inputname.restart.xsc] 
firsttimestep $firsttime 
}
} else { 
firsttimestep 0 
}
        
