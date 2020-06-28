#mol1 - reference, mol2 - wwhat need to move
proc allign { mol1 mol2 } {
	set reference_sel  [atomselect $mol1 "protein backbone"]
	set comparison_sel [atomselect $mol2 "protein backbone"]
	set transformation_mat [measure fit $comparison_sel $reference_sel]
	set move_sel [atomselect $mol2 "all"]
	$move_sel move $transformation_mat
}
