#Extract infor
proc extract_node {mol in_file}{
	set in_file [open $in_file]
	set node_list [split [read $in_file] "\n"]
	set num_nodes [llength $node_list]
	foreach item $node_list {
		set nodeID_str [regexp -inline {\[.+?]} $item
		set nodeID_wo_brac [regsub -all {\[|\]} $nodeID_str ""]
#setup was done to get the list of nodes bla blaaa		
	for {set i 0}{$i <$num_nodes}{incr i}{
}


proc shell_wat_com {top dum_sel real_sel  f_name {wrap "yes" }} { 
	set num_steps [molinfo $mol get numframes]
	set list_wat_cnt [list ]
	set outfile [open $f_name w]
	if { $wrap == "yes" } {
		package require pbctools
		pbc wrap -center com -centersel "$sel" -all -compound residue
	}
	for {set i 0} {$i < $num_steps} {incr i} {
		molinfo top set frame $i
		set com_coor [ center_of_mass $real_sel ]
		set cutoff [ measure rgyr $real_sel ]
		$dum_sel moveto $com_coor
		set sel1 [atomselect top "water and oxygen and pbwithin $cutoff of ($sel)"]
		set num_water [$sel1 num]
		lappend list_wat_cnt $num_water
		puts $outfile "$i $num_water"
		$sel1 delete
	}
	close $outfile
	return $list_wat_cnt
}

proc center_of_mass {selection} {
	# some error checking
	if {[$selection num] <= 0} {
	error "center_of_mass: needs a selection with atoms"
	}
	set the center of mass to 0
	set com [veczero]
	# set the total mass to 0
	set mass 0
	[$selection get {x y z}] returns the coordinates {x y z}
	[$selection get {mass}] returns the masses
	# so the following says "for each pair of {coordinates} and masses,
	# do the computation ..."
	# foreach coord [$selection get {x y z}] m [$selection get mass] {
	sum of the masses
	set mass [expr $mass + $m]
	#sum up the product of mass and coordinate
	set com [vecadd $com [vecscale $m $coord]]
	}
	# and scale by the inverse of the number of atoms
	if {$mass == 0} {
	error "center_of_mass: total mass is zero"
	}
	# The "1.0" can’t be "1", since otherwise integer division is done
	return [vecscale [expr 1.0/$mass] $com]
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
puts "Distribution function loaded"
#distribution
proc distribution { d_array_list {mol "top"} {f_name "na"} {num_bins "100"} {if_print "0"} args } {
        #args are for dihedral like populational analysis
        #upvar 1 $d_array1 d_array
        #set array_size [llength $d_array1]
        #puts "list is $d_array_list"
	puts "caluclating normalized distribution"
        for {set i 0} { $i < [llength $d_array_list]} {incr i} {
                puts "$i"
                set t [lindex $d_array_list $i]
                set d_array($i) $t
        }
        set num [molinfo $mol get numframes]
        #puts "33"
        if {[string length $args] == 0} {
                set d_min [expr $d_array(0)]
                set d_max [expr $d_array(0)]
        } else {
		puts "args detected. Using defined min max in args"
                set d_min [lindex $args 0]
                set d_max [lindex $args 1] 
        }
        #puts "33"
        #set d_min [lindex $d_array 0]
        #set d_max [lindex $d_array 0]
        for {set x 0} {$x < $num} {incr x} {
                set d_temp [expr $d_array($x)]
                #puts "44"
                if {$d_temp < $d_min} {set d_min $d_temp}
                if {$d_temp > $d_max} {set d_max $d_temp}
        }
	puts "min and max are $d_min , $d_max"
        set N_d $num_bins
        set dr [expr ($d_max - $d_min) /($N_d - 1)]
        #puts "$dr"
        for {set k 0} {$k < $N_d} {incr k} {
                set distribution($k) 0
        }
        for {set i 0} {$i < $num} {incr i} {
                set k [expr int(($d_array($i) - $d_min) / $dr)]
                incr distribution($k)
        }
        #parray distribution
        #puts "55"
        #normalizing section
        set t_area 0
        #set tot [llength $d_array_list]
        for {set i 0} {$i < $N_d} {incr i} {
                set t_area [expr ($t_area + (($distribution($i)+0.0) * $dr) )]
                #puts "$t_area $distribution($k) $dr"
        }
        #puts "b4 $t_area"
        for {set i 0} {$i < $N_d} {incr i} { 
                set distribution($i) [ expr ( ($distribution($i) + 0.0) / ($t_area + 0.0 ))]
        }
        #parray distribution
        if {$if_print == 1} {
                set outfile [open $f_name w]
                for {set k 0} {$k < $N_d} {incr k} {
                        puts $outfile "[expr $d_min + $k * $dr] $distribution($k)"
                }
                #puts "77"
                close $outfile
        } else {
                #puts "88"
                #if output is not requested to a file, returning a list with distribution and index
                set element_size [expr ($N_d)]
                #set x_y_val [ lrepeat 2 0]
                set x_y_val {}
                #set x_val [lrepeat $element_size 0]
                #set y_val [lrepeat $element_size 0]
                set x_val {}
                set y_val {}
                for {set k 0} {$k < $N_d} {incr k} {
                        #puts "$k $N_d"
                        #lset x_val $k [expr $d_min + $k * $dr]
                        lappend x_val [expr ($d_min + $k * $dr)]
                        #lset y_val $k $distribution($k)
                        lappend y_val $distribution($k)
                        #puts "$k"
                }
                #to see if normalized
                #set t_area 0
                #for {set k 0} {$k < $N_d} {incr k} {
                #        set t_area [expr ($t_area + ($distribution($k) * $dr) )]
                #}
                #puts "after $t_area"
                #lset x_y_val 0 $x_val
                #lset x_y_val 1 $y_val
                #puts "[lindex $x_y_val 0]"
                #return [list $x_y_val]
		lappend x_y_val $x_val
		lappend x_y_val $y_val
		return [list $x_y_val]
        }

        #lappend x_y_val $x_val
        #lappend x_y_val $y_val
        #puts "[lindex $x_y_val 0]"
        #puts "[lindex $x_y_val 1]"
        #puts "$x_y_val"
        #return [list $x_y_val]
}

