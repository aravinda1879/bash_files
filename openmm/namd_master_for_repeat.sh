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

#solvating the system
if [[ $water_shell == "yes" ]] ; then
echo "runnig water shell method"
sed -i "s/boxtype/ws/g" ../namd_variables.sh
cat << EOF > $tcl_f7
package require solvate
solvate ../${psf_f} ../${pdb_f} -t ${buf_d} -o ${infile}_wb
exit
EOF
cat << EOF > shell_water.tcl
mol load psf "${infile}_wb.psf"
mol addfile "${infile}_wb.pdb"
set sel1 [atomselect top "same residue as within $shell_cut of (all not water and not ion)"]
#cant add wb here cz ionization is not universal
\$sel1 writepsf ${infile}_ws.psf
\$sel1 writepdb ${infile}_ws.pdb
exit
EOF
vmd -dispdev text -eofexit < $tcl_f7 > output_solvation.log
vmd -dispdev text -eofexit < shell_water.tcl > shell_water.log

elif [[ $cubic_box == "yes" ]] ; then
sed -i "s/boxtype/wb/g" ../namd_variables.sh
bash ${HOME}/bash/namd/solvate_cubic_box.sh
vmd -dispdev text -eofexit < $tcl_f7 > output_solvation.log
vmd -dispdev text -eofexit < $tcl_f8 > output_solvation_add.log
vmd -dispdev text -eofexit < $tcl_f9 > output_solvation_remove_overlap.log

elif [[ $implicitSolvent == "1" ]]; then
sed -i "s/boxtype/implicit/g" ../namd_variables.sh
cp ../${psf_f} ${infile}_implicit.psf
cp ../${pdb_f} ${infile}_implicit.pdb
else
cat << EOF > $tcl_f7
package require solvate
solvate ../${psf_f} ../${pdb_f} -t ${buf_d} -o ${infile}_wb
exit
EOF
vmd -dispdev text -eofexit < $tcl_f7 > output_solvation.log
fi

#neutralizing the system.
cat << EOF > $tcl_f3
mol load psf "${infile}_wb.psf"
mol addfile "${infile}_wb.pdb"
package require autoionize
autoionize -psf ${infile}_wb.psf -pdb ${infile}_wb.pdb -sc $salt_con -from 3 -between 3 
EOF

#vmd -dispdev text -eofexit < $tcl_f0 > output_solvation.log
if [[ $implicitSolvent == "1" ]] ; then
echo "Running the implicit method"
sed -i "s/ionized.pdb/${infile}_implicit.pdb/g" $tcl_f2
vmd -dispdev text -eofexit < $tcl_f2 > constrain.log

elif [[ $water_shell == "yes" ]]; then
sed -i 's/_wb.psf/_ws.psf/g' $tcl_f3
sed -i 's/_wb.pdb/_ws.pdb/g' $tcl_f3

vmd -dispdev text -eofexit < $tcl_f3 > output_neutral.log
#restrain.pdb file 
vmd -dispdev text -eofexit < $tcl_f2 > constrain.log

else

vmd -dispdev text -eofexit < $tcl_f3 > output_neutral.log
vmd -dispdev text -eofexit < $tcl_f1 > output_cellvec.log
vmd -dispdev text -eofexit < $tcl_f2 > constrain.log
fi


#vmd -dispdev text -eofexit < $tcl_f4 > output_vmd5.log

#making conf files 
echo "Done playing with VMD"

if [[ $water_shell == "yes" ]] ; then
rm *wb.pdb
rm *wb.psf
cp ${infile}_wb* ../$dir3/.
cp ionized.pdb ../$dir3/${infile}_ws.pdb
cp ionized.psf ../$dir3/${infile}_ws.psf
cp -r $tcl_f4 ../$dir3/.

elif [[ $implicitSolvent == "1" ]] ; then 
cp ${infile}_implicit.psf ../$dir3/.
cp ${infile}_implicit.pdb ../$dir3/.

else 

cp ${infile}_wb* ../$dir3/.
cp ionized.pdb ../$dir3/${infile}_wb.pdb
cp ionized.psf ../$dir3/${infile}_wb.psf
cp -r $tcl_f4 ../$dir3/.
fi

cd ../$dir3
bash ~/bash/openmm/md_maker.sh
bash ~/bash/openmm/chomm_maker.sh
bash ~/bash/openmm/run.sh
if [[ $water_shell == "yes" ]] ; then
bash ~/bash/openmm/watershell_dyn.sh
bash ~/bash/openmm/mkmass_vmd.sh
vmd -dispdev text -eofexit < mkmass.vmd > mkmass.logt
fi
#making the gpu and cpu script file and 
#chk which cluster we are working on and do changes strings - hvd, doe, hpg2
if [[ $cluster == "hvd" ]] ; then
bash ${HOME}/bash/openmm/harvard_cpu_script.sh
bash ${HOME}/bash/openmm/harvard_gpu_script.sh
#bash ${HOME}/bash/openmm/rmaid ${final_pdb_f%.*}-mass.pdb > ${final_pdb_f%.*}-rmaid.pdb
#sed -i '/set dir1/c\set dir1     \/n\/karplus_lab\/aravinda1879\/namd\/toppar' *conf

elif [[ $cluster == "doe" ]] ; then
	echo "none"
else
#sed -i '/stepspercycle/c\CUDASOAintegrate on' *md*conf *eq*conf
sed -i '/set dir1/c\set dir1     ../toppar' *conf
bash ${HOME}/bash/namd/uf_cpu_script.sh
bash ${HOME}/bash/namd/uf_gpu_script.sh

fi
cp ../$dir2/restraint.pdb .
sed -i '/CRYST1/d'  *.pdb
cd ..
#echo "to copy use following"
#echo "scp -r ${dir3} aravinda1879@sftp.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/."
#scp -r ${dir2} ${dir3} aravinda1879@hpg2.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/.
