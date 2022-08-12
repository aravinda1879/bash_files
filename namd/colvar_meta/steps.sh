#4 is up
#for i in `seq 1 11`;
#sl=( 0.15 0.3 1.5 3.0 6.0 )
#sl=(0.0 0.15 0.3 1.0 1.5 2.0 2.5 3.0 5.0 )
sl=( 0.15 )
Tls=( 300 )
#fnames=(pDMAEMA30_syn_opt0 pDMAEMA30_syn_opt1 ) 
#fnames=(pDMAEMA75_ata_s4 pDMAEMA75_ata_s5 )
fnames=(  cfab_mod13_heated  )
for file  in ${fnames[@]};
do
for T in ${Tls[@]};
do
for j in ${sl[@]};
do 
for i in `seq 1 1`;
do
work_file=${file}
fol=${work_file}_${j}M_${T}K_wb
mkdir ${fol}
#grep -E 'U1|U2|U3' ${f_prefix}.pdb >  ${prefix}/${prefix}.pdb
#grep -E 'U3' a${i}.pdb >> ${prefix}/${prefix}.pdb
cp ${work_file}.pdb ${fol}/${work_file}.pdb
cp ${work_file}.psf ${fol}/${work_file}.psf
cd ${fol}
#bash ~/bash/openmm/var_list_for_repeat.sh ${work_file} ${j} ${T} hvd
#sed -i "s/_wb/_ws/g" namd_variables.sh 
#bash ~/bash/openmm/namd_master_for_repeat.sh
bash ~/bash/namd/var_list_for_repeat.sh ${work_file} ${j} ${T} hvd
bash ~/bash/namd/namd_master_for_repeat.sh
cd ..
done
done
done
done
