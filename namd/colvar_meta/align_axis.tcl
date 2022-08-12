
set mol [mol new "7k8m_c102_wuhan.psf" type psf waitfor all]
mol addfile "7k8m_c102_wuhan.pdb" waitfor all molid $mol
set all [atomselect top "all"] 
set sel1 [atomselect top "chain H and  within 5 of chain R"] 
set sel2 [atomselect top "chain R and  within 5 of chain H"] 

set com1 [measure center $sel1]
set com2 [measure center $sel2]

set dir1 [vecsub $com2 $com1]
#draw cylinder $com2 $com1 radius 1

set M [transvecinv $dir1]
$all move $M
set M [transaxis y -90]
$all move $M

animate write pdb 7k8m_c102_wuhan_metaZ.pdb sel $all top
$all writepsf 7k8m_c102_wuhan_metaZ.psf
#vmd -dispdev text -eofexit < align_axis.tcl > temp.log
#rm temp.log

