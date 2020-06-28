#ana_type1=( "images" "rg" "sasa" "radial" "dihedral"  "e2e" "contact" "distance" "angle" "shape" "rmsd" "volmap" "caver" "contact_wat" "contact_wat_dipole")
#ana_type1=( "gamdFE" )
ana_type1=( "rg" "e2e"  "gamdFE" )
post_fix=(${ana_type1[@]})
current_folder=`pwd`
file_list_N=( "$@" )
for i in ${post_fix[@]} ; do
bash ${anash_ara}/setup_ana_md_${i}.sh ${file_list_N[@]}
echo "done analysing $i"
done

