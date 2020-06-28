proc vicinRatio {R start end fout} {
    set outfile [open $fout w]
    set sel [atomselect top "protein"]
    set reslist [lsort -unique [$sel get resname]]
    set W [atomselect top "oxygen and water"]
    set P [atomselect top "oxygen and resname PEGM"]
    set Wtot [$W num]
    set Ptot [$P num]
    set bulk [expr {double($Ptot)/(4*double($Wtot))}]
    package require pbctools
    pbc wrap -center com -centersel "protein" -all -compound residue
    set nframe [molinfo top get numframes]
    set nframe [expr $end - $start + 1]
    set end2 [molinfo top get numframes]
    foreach res $reslist {
        set WL [atomselect top "oxygen and water and pbwithin $R of resname $res"]
        set PL [atomselect top "oxygen and resname PEGM and pbwithin $R of resname $res"]
        set Wcount 0
        set Pcount 0
        set wval 0
        set pval 0
        for {set frame $start} {$frame  <= $end2} {incr frame} {
            $WL frame $frame
            $WL update
            $PL frame $frame
            $PL update
            set wval [$WL num]
            set pval [$PL num]
            set Wcount [expr {$Wcount + 4*($wval)}]
            set Pcount [expr {$Pcount + $pval}]
        }
                puts ", '$res' : [expr {double($Pcount)/double($Wcount)/double($bulk)}]"
        puts $outfile "$res    [expr {double($Pcount)/double($Wcount)/double($bulk)}]"
    }
    puts "Bulk ratio : $bulk"
    close $outfile
}
