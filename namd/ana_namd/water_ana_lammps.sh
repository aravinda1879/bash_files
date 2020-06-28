#!/bin/bash
file_psf=$( ls ../../*psf )
cat << EOF > analysis_h2o.tcl
source /home/aravinda1879/bash/namd/ana_namd/vmd_proc.tcl
source /home/aravinda1879/bash/namd/ana_namd/bigdcd.tcl
set mol [mol new "${file_psf}" type psf waitfor all]
#test
EOF
for file_dcd in $( ls ../../*ps_traj/dump* | sort --version-sort ) ; do

cat << EOF >> analysis_h2o.tcl
mol addfile "$file_dcd" type dcd first 0 last -1 step 1  waitfor all molid \$mol
EOF
done

