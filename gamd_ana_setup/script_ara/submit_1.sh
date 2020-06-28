cur_dir="/scratch3/aravinda1879/zwitterionic_gamd"
script_ara="/scratch3/aravinda1879/zwitterionic_gamd/script_ara"
export anash_ara="/scratch3/aravinda1879/zwitterionic_gamd/script_ara/ana_sh"
cd $cur_dir


sl=( 0.0 0.3 1.0 2.0 3.0 5.0)
#sl=( 0.0 )
Tls=(  310.5 )
#Tls=(  303 )
pol_lst=(pSBMA )

fnames=()


for pol in ${pol_lst[@]}; do 
for i in `seq 1 5`; do
fnames=(  ${fnames[@]}  ${pol}n${i}_18_ata )
done
done

<< for_random_stuff
for file in ${fnames[@]}; do
for T in ${Tls[@]}; do
for j in ${sl[@]}; do
work_file=$file        
fol=${work_file}_${j}M_${T}K_gamd_10ps
cd $fol
mv *gmd0.log log_md/.
cd $cur_dir
done
done 
done
for_random_stuff


# << no_gamdall

for file  in ${fnames[@]};
do
for T in ${Tls[@]};
do
for j in ${sl[@]};
do 
work_file=$file
fol=${work_file}_${j}M_${T}K_gamd_10ps
file_list_N=( ${file_list_N[@]} ${fol}  )
for i in `seq 1 3`;
do
fol2=${fol}/imd_$i
file_list_N=( ${file_list_N[@]} ${fol2}  )
done
done
done
done
bash ${script_ara}/setup_ana_md_1.sh ${file_list_N[@]}
#export PYTHONPATH=$PYTHONPATH:"/home/aravinda1879/anaconda3/lib/python3.6/site-packages/"

#echo "${file_list_N[@]}"
# for volmap and combinepca sub folders are not required just run setup_ana_md_1.sh
#bash ${script_ara}/setup_ana_md_1.sh ${pre_lst[@]}
#no_gamdall


<<only_for_gamdFE_all


for file  in ${fnames[@]};
do
for T in ${Tls[@]};
do
for j in ${sl[@]};
do 
work_file=$file
fol=${work_file}_${j}M_${T}K_gamd_10ps
file_list_N=( ${file_list_N[@]} ${fol}  )
done
done
done
bash ${script_ara}/setup_ana_md_1.sh ${file_list_N[@]}
#export PYTHONPATH=$PYTHONPATH:"/home/aravinda1879/anaconda3/lib/python3.6/site-packages/"

only_for_gamdFE_all


