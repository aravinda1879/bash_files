#! /bin/bash
source ~/bash/namd/charmm_lib.sh
#echo "Please check if variable file saved?"
#echo "if not please load following command"
source  ${HOME}/bash/namd/charmm_lib.sh
#bash ${HOME}/bash/namd/var_list.sh
#gedit namd_variables.sh
source namd_variables.sh
echo "FIles will be prepared for ${cluster} cluster"
#copying library files
mkdir $dir2
mkdir $dir3
cd $dir2
#making required files 
#Preperation of solvated pdb & psf
#echo "Enter the buffering distance"
#read buf_d

#making the cell vector calculating tcl ${tcl_f1}
#bash ~/bash/charmm_polymer_prep.sh
bash ${HOME}/bash/namd/mov_to_origin.sh
vmd -dispdev text -eofexit < $tcl_f6 > move_to_origin.log
bash ${HOME}/bash/namd/cell_vector.sh
bash ${HOME}/bash/namd/constrain_pdb.sh
if [ $cubic_box == "yes" ] ; then
bash ${HOME}/bash/namd/solvate_cubic_box.sh
vmd -dispdev text -eofexit < $tcl_f7 > output_solvation.log
vmd -dispdev text -eofexit < $tcl_f8 > output_solvation_add.log
vmd -dispdev text -eofexit < $tcl_f9 > output_solvation_remove_overlap.log
else
cat << EOF > $tcl_f7
package require solvate
solvate ../${psf_f} ../${pdb_f} -t ${buf_d} -o ${infile}_wb
exit
EOF
vmd -dispdev text -eofexit < $tcl_f0 > output_solvation.log

fi
#neutralizing the system.
cat << EOF > $tcl_f3
mol load psf "${infile}_wb.psf"
mol addfile "${infile}_wb.pdb"
package require autoionize
autoionize -psf ${infile}_wb.psf -pdb ${infile}_wb.pdb -sc $salt_con -from 3 -between 3 
EOF
#making of minimized pdb with protein restrained
cat << EOF > $tcl_f4
mol new ${infile}_wb.psf
mol addfile ${infile}_wb_min_2.coor
set sel [atomselect top all]
set sel2 [atomselect top "protein"]
\$sel set beta 0.0
\$sel2 set beta 1.0
\$sel writepdb restraint2.pdb
EOF

#vmd -dispdev text -eofexit < $tcl_f0 > output_solvation.log
vmd -dispdev text -eofexit < $tcl_f3 > output_neutral.log
vmd -dispdev text -eofexit < $tcl_f1 > output_cellvec.log
vmd -dispdev text -eofexit < $tcl_f2 > bin2pdb.log
#vmd -dispdev text -eofexit < $tcl_f4 > output_vmd5.log

#making conf files 
echo "Done playing with VMD"
bash ${HOME}/bash/namd/conf_min_water.sh
bash ${HOME}/bash/namd/conf_min_all.sh
bash ${HOME}/bash/namd/conf_heat_equillibration.sh
bash ${HOME}/bash/namd/conf_production.sh

#gamd configuration files
bash ${HOME}/bash/namd/gamd/conf_production_cmd_gamd.sh
for imd in `seq 1 3`;
do 
mkdir imd_$imd
cd imd_$imd
bash ${HOME}/bash/namd/gamd/conf_production_gamd.sh $imd

for i in `seq 1 $run_repeat`;
do
export j=$i
#echo "additional $i conf file was prited"
bash ${HOME}/bash/namd/gamd/conf_production_gamd_rest.sh $imd
done
echo "additional $i conf file was prited"
#making the gpu and cpu script file and 
#chk which cluster we are working on and do changes strings - hvd, doe, hpg2
if [[ $cluster == "hvd" ]] ; then
#bash ${HOME}/bash/namd/harvard_cpu_script.sh
bash ${HOME}/bash/namd/gamd/harvard_gpu_script.sh
sed -i '/set dir1/c\set dir1     \/n\/karplus_lab\/aravinda1879\/namd\/toppar' *conf
#sed -i '/stepspercycle/c\CUDASOAintegrate on' *conf
#sed -i '/par_all36_carb.prm/d'  *conf
sed -i '/par_all36_na.prm/d' *conf
sed -i '/par_water_ions.prm/d' *conf
sed -i '/par_all36_cgenff.prm/d' *conf
sed -i '/par_all35_ethers_oh.prm/d' *conf
sed -i '/par_all36m_prot.prm/d' *conf

elif [[ $cluster == "doe" ]] ; then
	echo "none"
else

sed -i '/set dir1/c\set dir1     ../toppar' *conf
bash ${HOME}/bash/namd/gamd/cpu_script.sh
bash ${HOME}/bash/namd/gamd/gpu_script.sh

fi

cd ..
cp -r imd_$imd ../$dir3/.
done

#coping all required files to running directory
cp ${infile}_wb* ../$dir3/.
cp ionized.pdb ../$dir3/${infile}_wb.pdb
cp ionized.psf ../$dir3/${infile}_wb.psf
cp restraint.pdb ../$dir3/restraint.pdb
cp -r $tcl_f4 ../$dir3/.
cd ../$dir3
#making the gpu and cpu script file and 
#chk which cluster we are working on and do changes strings - hvd, doe, hpg2
if [[ $cluster == "hvd" ]] ; then
#bash ${HOME}/bash/namd/gamd/harvard_cpu_script0.sh
bash ${HOME}/bash/namd/gamd/harvard_gpu_script0.sh
sed -i '/set dir1/c\set dir1     \/n\/karplus_lab\/aravinda1879\/namd\/toppar' *conf
#sed -i '/stepspercycle/c\CUDASOAintegrate on' *conf
#sed -i '/par_all36_carb.prm/d'  *conf
sed -i '/par_all36_na.prm/d' *conf
sed -i '/par_water_ions.prm/d' *conf
sed -i '/par_all36_cgenff.prm/d' *conf
sed -i '/par_all35_ethers_oh.prm/d' *conf
sed -i '/par_all36m_prot.prm/d' *conf

elif [[ $cluster == "doe" ]] ; then
	echo "none"
else

sed -i '/set dir1/c\set dir1     ../toppar' *conf
bash ${HOME}/bash/namd/gamd/cpu_script0.sh
bash ${HOME}/bash/namd/gamd/gpu_script0.sh

fi

cd ..


#echo "to copy use following"
#echo "scp -r ${dir3} aravinda1879@sftp.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/."
#scp -r ${dir2} ${dir3} aravinda1879@hpg2.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/.