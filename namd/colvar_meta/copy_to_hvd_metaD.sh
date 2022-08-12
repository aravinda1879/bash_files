#4 is up
#for i in `seq 1 11`;
#sl=( 0.15 0.3 1.5 3.0 6.0 )
#sl=(0.0 0.15 0.3 1.0 1.5 2.0 2.5 3.0 5.0 )
sl=( 0.0 )
Tls=( 300 )
#fnames=(pDMAEMA30_syn_opt0 pDMAEMA30_syn_opt1 ) 
#fnames=(pDMAEMA75_ata_s4 pDMAEMA75_ata_s5 )
fnames=(  gfp_bCD  )
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
#grep -E 'U1|U2|U3' ${f_prefix}.pdb >  ${prefix}/${prefix}.pdb
#grep -E 'U3' a${i}.pdb >> ${prefix}/${prefix}.pdb

rsync -avP ${fol}/project_run*/* aravinda1879@login.rc.fas.harvard.edu:/n/holyscratch01/karplus_lab/aravinda1879/${fol}_20ps
#scp -P 102 -r ${fol}/project_run* am1879@128.103.92.237:/home/am1879/md/mmp14_work/${fol}_20ps


done
done
done
done








#rsync -avP -e 'ssh -p 102'  A_AICHI_68_0.15M_300K/openmm_2 am1879@128.103.92.237:/home/am1879/.

#rsync -avP H1_kim_9K_0.15M_300K/project_run_H1_kim_9K_20ps/* aravinda1879@login.rc.fas.harvard.edu:/n/holyscratch01/karplus_lab/aravinda1879/H1_kim_9K_20ps
#rsync -avP -e 'ssh -p 102'  A_AICHI_68_0.15M_300K_xwat/toppar am1879@128.103.92.237:/home/am1879/.
#rsync -avP -e 'ssh -p 102'  A_AICHI_68_0.15M_300K_xwat/NAMD* am1879@128.103.92.237:/home/am1879/.
