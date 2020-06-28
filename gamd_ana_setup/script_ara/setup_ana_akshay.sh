ana_type1=( "e2e")
post_fix=(${ana_type1[@]})
current_folder=`pwd`
file_list_N=( "$@" )
for i in ${post_fix[@]} ; do
bash ${anash_ara}/setup_ana_md_${i}.sh ${file_list_N[@]}
echo "done analysing $i"
done
