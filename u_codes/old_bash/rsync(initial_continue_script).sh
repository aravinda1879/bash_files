!/bin/bash
echo "enter the final unique name (ending md* number)"
read cp_file 
echo "enter the final unique name for folder search in current dir (beging b5p* )"
read lsfl
for file in $( ls -d $lsfl ) ; do
cd $file
mkdir ${file}_cont
cd ${file}_cont
cp ../*md${cp_file}.restart.* .
cp ../*md${cp_file}.conf .
cp ../*script* .
cp ../*psf .
cp ../*pdb .
cd ../../
done
echo "ordering files"
for file in $( ls -d $lsfl ) ; do
cd $file
#bash ~/bash/namd/ana_namd/order_files.sh
scp  -r  ${file}_cont aravinda1879@hpg2.hpc.ufl.edu:/ufrc/colina/aravinda1879/namd/.
echo " done copying $file"
cd ..
done
for file in $( ls -d $lsfl ) ; do
cat << EOF >> cpu_sbatch.sh
cd ${file}_cont
sbatch *script*
cd ..
EOF
done
scp  -r  cpu_sbatch.sh aravinda1879@hpg2.hpc.ufl.edu:/ufrc/colina/aravinda1879/namd/.
