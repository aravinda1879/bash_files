#! /bin/bash
source ~/bash/namd/charmm_lib.sh
cp $pol_rtf .
cp $pol_prm .
cp $pol_inp .

ls 
echo "enter the cordfile (pdb) without extension"
read infile
#Variables
#psf_f=${infile}.psf
#pdb_f=${infile}.pdb
#tcl_f=${infile}_solvation.tcl
#export con_eq_f=${infile}_wb_eq.conf
#export con_pro_f=${infile}_wb_md.conf
#defining directories
#dir1=project_lib
#dir2=project_prep
#dir3=project_run

source  ${HOME}/bash/namd/charmm_lib.sh
bash ${HOME}/bash/namd/namd_var_list.sh
gedit namd_variables.sh
source namd_variables.sh
#copying library files
mkdir $dir1
mkdir $dir2
mkdir $dir3
cd $dir1
cd ../$dir2
#making required files 
# Preperation of solvated pdb & psf
#echo "Enter the buffering distance"
#read buf_d

#making the cell vector calculating tcl ${tcl_f1}
bash ~/bash/namd/charmm_polymer_prep.sh
cat << EOF > $tcl_f
package require solvate
solvate ${psf_f} ${pdb_f} -t ${buf_d} -o ${infile}_wb
source $tcl_f1
exit
EOF
vmd -dspdev text -e $tcl_f
cp _1.dat ${infile}_wb.* ../$dir3/
cd ../$dir3
#preperation of NAMD config file with parameters for the simultion
#
bash ${HOME}/bash/namd/namd_config_prep.sh
#making the script file
bash ${HOME}/bash/namd/namd_script.sh





