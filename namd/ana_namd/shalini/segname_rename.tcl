mol load pdb "kim_K9_renum.pdb"
set output "kim_K9_segname"
set temp_ch 0
set sel1 [atomselect top "protein"]
#set chains [lsort -unique [$sel1 get chain]]
#set seglst [lsort -unique [$sel1 get segname]]
foreach seg [list HA11 HA21 HA12 HA22 HA13 HA23] ch [list A B C D E F]  {
    set temp0  [atomselect top "chain ${ch}"]
    $temp0 set segname $seg 
}
set all [atomselect top all]
$all writepdb ${output}.pdb

