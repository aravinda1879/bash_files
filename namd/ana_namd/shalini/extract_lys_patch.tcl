mol load pdb "infile"
set out_put "out_file.mut"
#set sel1 "(resname LYS and segname HA11 HA21 ) and not ( same residue as  within 2 of (not  segname HA11 HA21))"
set sel1 "(resname LYS and segname HA11 HA21 )"
set man_sel "not (resname LYS and resid  117 139 174 307 310 51 62 68 88 and segname HA11 HA21)"
set num_res [ llength [ lsort -unique  [ [atomselect top "name CA"] get residue] ] ]
set num_res_ha11 [ llength [ lsort -unique  [ [atomselect top "name CA and segname HA11" ] get residue] ] ]
#set num_res_ha21 [ llength [ lsort -unique  [ [atomselect top "name CA and segname HA21" ] get residue] ] ]

set units 3
set sel_lys [ lsort -unique [[ atomselect top "${sel1} and ${man_sel}"] get residue ]]
set outfile [open $out_put w]

for {set i 0} { $i < $units} {incr i} {
    foreach residue ${sel_lys} {
	if { $residue < $num_res_ha11} {
	    puts -nonewline $outfile "HA1[expr $i+1]:[[atomselect top "residue $residue and name CA"] get resid] "
	} else {
	    puts -nonewline $outfile "HA2[expr $i+1]:[[atomselect top "residue $residue and name CA"] get resid] "
	}
    }
}
close $outfile
