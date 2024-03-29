#! /bin/bash
source ~/bash/namd/charmm_lib.sh
echo "Please check if variable file saved?"
echo "if not please load following command"
echo "bash ~/bash/namd/var_list.sh"
read dummy
source  ${HOME}/bash/namd/charmm_lib.sh
#bash ${HOME}/bash/namd/var_list.sh
#gedit namd_variables.sh
source namd_variables.sh
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
bash ${HOME}/bash/namd/cell_vector.sh
bash ${HOME}/bash/namd/constrain_pdb.sh
cat << EOF > $tcl_f0
package require solvate
solvate ../${psf_f} ../${pdb_f} -t ${buf_d} -o ${infile}_wb
exit
EOF
#neutralizing the system.
cat << EOF > $tcl_f3
mol load psf "${infile}_wb.psf"
mol addfile "${infile}_wb.pdb"
package require autoionize
autoionize -psf ${infile}_wb.psf -pdb ${infile}_wb.pdb -sc $salt_con 
EOF
#making of minimized pdb with protein restrained
cat << EOF > $tcl_f4
mol new ${infile}_wb.psf
mol addfile ${infile}_wb_min_2.coor
set sel [atomselect top all]
set sel2 [atomselect top "protein backbone"]
\$sel set beta 0.0
\$sel2 set beta 1.0
\$sel writepdb restraint2.pdb
EOF

vmd -dispdev text -eofexit < $tcl_f0 > output_solvation.log
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
echo "printing rest of the configuration files"
for i in `seq 1 $run_repeat`;
do
export j=$i
echo "additional $i conf file was prited"
bash ${HOME}/bash/namd/conf_production_rest.sh
done
echo "done printing configuration files"
#coping all required files to running directory
#cp conf* ../$dir3/.
cp ${infile}_wb* ../$dir3/.
cp ionized.pdb ../$dir3/${infile}_wb.pdb
cp ionized.psf ../$dir3/${infile}_wb.psf
cp restraint.pdb ../$dir3/restraint.pdb
cp -r $tcl_f4 ../$dir3/.
cd ../$dir3
#making the gpu and cpu script file
bash ${HOME}/bash/namd/cpu_script.sh
bash ${HOME}/bash/namd/gpu_script.sh
cd ..
echo "to copy use following"
echo "scp -r ${dir3} aravinda1879@sftp.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/."
#scp -r ${dir2} ${dir3} aravinda1879@hpg2.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/.
