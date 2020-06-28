#!/usr/local/bin/vmd

#load structure and trajectory
set mol [mol new water-nacl-big.psf type psf waitfor all]
mol addfile water-nacl-big.dcd type dcd waitfor all

# msd correlation length (in frames)
set msdlen 100
# time delta between frames (in ps)
set delt 1.0
# atom selection string
set atmname "name NA"
# output filename
set outfile "NA-msd.dat"

########################################################################
# no user servicable parts below
########################################################################

# for numerical derivatives
package require sgsmooth 1.1

set sel [atomselect $mol $atmname]
set idxlist [$sel get index]
$sel delete

# number of msd data sets
set nummsd 0

# initialize msd array
for {set i 0} {$i < $msdlen} {incr i} {
    set msd($i) 0.0
}

# loop over residues
foreach idx $idxlist {
    puts "processing index $idx"
    set poslist {}
    set sel [atomselect $mol "index $idx"]

    # fill poslist
    for {set i 0} {$i < $msdlen} {incr i} {
        $sel frame $i
        lappend poslist [measure center $sel]
    }

    # compute msd for the rest of the trajectory
    set nf [molinfo $mol get numframes]
    for {set i $msdlen} {$i < $nf} {incr i} {

        set ref [lindex $poslist 0]
        set poslist [lrange $poslist 1 end]

        $sel frame $i
        lappend poslist [measure center $sel]

        set j 0
        foreach pos $poslist {
            set msd($j) [expr $msd($j) + [veclength2 [vecsub $ref $pos]]]
            incr j
        }
        incr nummsd
    }
    
    $sel delete
}

set tval {}
set msdval {}

# normalize and build lists for output
for {set i 0} {$i < $msdlen} {incr i} {
    lappend tval [expr $delt * ($i +1)]
    lappend msdval [expr $msd($i)/$nummsd]
}

# compute numerical derivative
set msdder [sgsderiv $msdval 2 4]

# write out
set fp [open $outfile w]
foreach t $tval m $msdval d $msdder {
    puts $fp "$t  $m  [expr {$d/6.0}]"
}
close $fp
