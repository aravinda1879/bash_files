cur_dir="/scratch3/aravinda1879/zwitterionic_gamd"
script_ara="/scratch3/aravinda1879/zwitterionic_gamd/script_ara"
export anash_ara="/scratch3/aravinda1879/zwitterionic_gamd/script_ara/ana_sh"
cd $cur_dir


sl=( 0.0 0.3 1.0 2.0 3.0 5.0)
Tls=(  310.5 )
pol_lst=(pCBMA)

fnames=()

for pol in ${pol_lst[@]}; do 
for i in `seq 1 5`; do
fnames=(  ${fnames[@]}  ${pol}n${i}_18_ata )
done
done

for file  in ${fnames[@]};
do
for T in ${Tls[@]};
do
for j in ${sl[@]};
do 
work_file=$file
fol=${work_file}_${j}M_${T}K_gamd_10ps

for i in `seq 1 3`;
do
fol2=${fol}/imd_$i
file_list_N=( ${file_list_N[@]} ${fol2}  )
done
done
done
done

#file_list_N has all files in it that will be analyze

bash ${script_ara}/setup_ana_akshay.sh ${file_list_N[@]}
