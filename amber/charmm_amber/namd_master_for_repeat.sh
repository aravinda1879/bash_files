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
autoionize -psf ${infile}_wb.psf -pdb ${infile}_wb.pdb -sc $salt_con 
EOF


vmd -dispdev text -eofexit < $tcl_f3 > output_neutral.log
vmd -dispdev text -eofexit < $tcl_f1 > output_cellvec.log
vmd -dispdev text -eofexit < $tcl_f2 > bin2pdb.log
#vmd -dispdev text -eofexit < $tcl_f4 > output_vmd5.log

#making conf files 
echo "Done playing with VMD"

cp ${infile}_wb* ../$dir3/.
cp ionized.pdb ../$dir3/${infile}_wb.pdb
cp ionized.psf ../$dir3/${infile}_wb.psf

cd ../$dir3
# seperate water
cat << EOF > $tcl_f6
mol load psf "${infile}_wb.psf"
mol addfile "${infile}_wb.pdb"
set not_water [atomselect top " all not water"]
set water [atomselect top "water"]
\$not_water writepdb ${infile}_NOwb.pdb
\$not_water writepsf ${infile}_NOwb.psf
\$water writepdb wb.pdb
\$water writepsf wb.psf
EOF
# make water with the tip3p bond
cat << EOF > $tcl_f7
package require psfgen
package require topotools
mol load psf "wb.psf"
mol addfile "wb.pdb"
set no_CW [atomselect top "water and not segname CW"]
set nlist {}
set blist [\$no_CW getbonds]
foreach {o h1 h2} \$blist {
topo addbond [lindex \$o 0] [lindex \$o 1]
}
set water [atomselect top "water"]
\$water writepsf Twb.psf
\$water writepdb Twb.pdb
quit
EOF
# add water with the tip3p bond

cat << EOF > $tcl_f8
package require psfgen
topology /home/aravinda1879/Dropbox/toppar/top_all36_prot.rtf
topology /home/aravinda1879/Dropbox/toppar/toppar_water_ions.str
pdbalias residue HOH TIP3
pdbalias atom HOH O OH2
pdbalias residue HOH TIP3
readpsf ${infile}_NOwb.psf pdb ${infile}_NOwb.pdb
readpsf Twb.psf pdb Twb.pdb
coordpdb ${infile}_NOwb.pdb
coordpdb Twb.pdb
guesscoord
writepdb ${infile}_tip3pwb.pdb
writepsf ${infile}_tip3pwb.psf
quit

EOF
vmd -dispdev text -eofexit < $tcl_f6 > seperate_water.log
vmd -dispdev text -eofexit < $tcl_f7 > make_tip3p_water.log
sleep 1
echo " Done making tip3p water"
vmd -dispdev text -eofexit < $tcl_f8 > add_tip3p_water.log


#convert the tip3p water box structure to amber input
cat << EOF > $tcl_f9
chamber -top $toppar_dir/top_all36_prot.rtf -top $toppar_dir/top_all35_ethers_oh.rtf  -top $toppar_dir/top_all36_cgenff.rtf  -param $toppar_dir/par_all36m_prot.prm -param $toppar_dir/par_water_ions.prm -param $toppar_dir/par_all35_ethers_oh.prm -param $toppar_dir/par_all36_cgenff.prm   -param $toppar_dir/$linker_prm_file1 -param $toppar_dir/$linker_prm_file2 -param $toppar_dir/$linker_prm_file3 -param $toppar_dir/$linker_prm_file4 -param $toppar_dir/$linker_prm_file5  -psf ${infile}_tip3pwb.psf -crd ${infile}_tip3pwb.pdb  -box bounding
outparm ${infile}_wb.prmtop ${infile}_wb.inpcrd
HMassRepartition 
outparm ${infile}_HMR_wb.prmtop ${infile}_HMR_wb.inpcrd
EOF
parmed -i parmed.tcl > parmed_out.log
cd ..
# select water get inside the axels loopfor H H bond make the topo bond.
#echo "to copy use following"
#echo "scp -r ${dir3} aravinda1879@sftp.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/."
#scp -r ${dir2} ${dir3} aravinda1879@hpg2.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/.
