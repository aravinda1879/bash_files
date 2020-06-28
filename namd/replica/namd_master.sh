#! /bin/bash
source ~/bash/namd/charmm_lib.sh
echo "Please check if variable file saved?"
echo "if not please load following command"
echo "bash ~/bash/namd/var_list.sh"
read dummy


source namd_variables.sh
#copying library files
mkdir $dir2
mkdir $dir3
cd $dir2

cp ../$psf_f .
cp ../$pdb_f .
cp ../$Bincoordinates .
bash ${HOME}/bash/namd/replica/constrain_pdb.sh
vmd -dispdev text -eofexit < $tcl_f2 > occupancy_selection.log

###################################
cat << EOF > replica_tcl_var.conf
set num_replicas $num_replicas
set min_temp $min_temp
set max_temp $max_temp
set TEMP $TEMP
set steps_per_run $steps_per_run
set num_runs $num_runs
# num_runs should be divisible by runs_per_frame * frames_per_restart
set runs_per_frame $runs_per_frame
set frames_per_restart $frames_per_restart
set namd_config_file "common.conf"
set output_root "output/%s/${infile2}" ; # directories must exist

# the following used only by show_replicas.vmd
set psf_file "$psf_f"
set initial_pdb_file "$pdb_f"
set fit_pdb_file "$pdb_f"
EOF
###################################

#################
cat << EOF > job0.conf
source replica_tcl_var.conf

# prevent VMD from reading replica.namd by trying command only NAMD has
if { ! [catch numPes] } { source ../replica.namd }
EOF
#################

bash ${HOME}/bash/namd/replica/conf_replica_1.sh
bash ${HOME}/bash/namd/replica/rest2_remd.sh

for j in `seq 1 $run_repeat`;
do
###################################
cat << EOF > job${j}.conf
source replica_tcl_var.conf
source [format \$output_root.job$(($j-1)).restart$(($j * $steps_per_run * $num_runs )).tcl ""]
set num_runs $(( ($j+1) * $steps_per_run * $num_runs ))
# prevent VMD from reading replica.namd by trying command only NAMD has
if { ! [catch numPes] } { source ../replica.namd }
EOF
###################################
done

cp ${psf_f} ../$dir3/.
cp ${pdb_f} ../$dir3/.
cp ../$Bincoordinates  ../$dir3/.
cp ../$extendedsystem  ../$dir3/.
cp *conf ../$dir3/.
cp res2_remd.namd ../$dir3/.
cp scale_rst.spt ../$dir3/.
cd ../$dir3
#making the gpu and cpu script file
echo "done generating files"
bash ${HOME}/bash/namd/replica/cpu_script.sh
bash ${HOME}/bash/namd/replica/gpu_script.sh
cd ..
echo "to copy use following"
echo "scp -r ${dir3} aravinda1879@sftp.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/replica."
#scp -r ${dir2} ${dir3} aravinda1879@hpg2.rc.ufl.edu:/ufrc/colina/aravinda1879/namd/replica.
