#! /bin/bash
source ~/bash/namd/charmm_lib.sh
#echo "Please check if variable file saved?"
#echo "if not please load following command"
source  ${HOME}/bash/namd/charmm_lib.sh
#bash ${HOME}/bash/namd/var_list.sh
#gedit namd_variables.sh
source namd_variables.sh
#copying library files
mkdir $dir2
mkdir $dir3
cd $dir2

bash ${HOME}/bash/namd/implicit/constrain_pdb.sh
vmd -dispdev text -eofexit < $tcl_f2 > constrain_pdb.log

#making of minimized pdb with protein restrained
cat << EOF > $tcl_f4
mol new $psf_f
mol addfile ${infile}_min_2.coor
set sel [atomselect top all]
set sel2 [atomselect top "protein backbone"]
\$sel set beta 0.0
\$sel2 set beta 1.0
\$sel writepdb restraint2.pdb
EOF


#making conf files 
echo "Done playing with VMD"
bash ${HOME}/bash/namd/implicit/conf_min_water.sh
bash ${HOME}/bash/namd/implicit/conf_min_all.sh
bash ${HOME}/bash/namd/implicit/conf_heat_equillibration.sh
bash ${HOME}/bash/namd/implicit/conf_production.sh
echo "printing rest of the configuration files"
for i in `seq 1 $run_repeat`;
do
export j=$i
echo "additional $i conf file was prited"
bash ${HOME}/bash/namd/implicit/conf_production_rest.sh
done
echo "done printing configuration files"
#coping all required files to running directory
#cp conf* ../$dir3/.
cp ${infile}_* ../$dir3/.
cp restraint.pdb ../$dir3/restraint.pdb
cp -r $tcl_f4 ../$dir3/.
cd ../$dir3
cp ../$psf_f .
cp ../$pdb_f .
#making the gpu and cpu script file
bash ${HOME}/bash/namd/implicit/cpu_script.sh
bash ${HOME}/bash/namd/implicit/gpu_script.sh
cd ..
#echo "to copy use following"
#echo "scp -r ${dir3} aravinda1879@sftp.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/."
#scp -r ${dir2} ${dir3} aravinda1879@hpg2.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/.
