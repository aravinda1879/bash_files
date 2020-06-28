#!/bin/bash
file_psf=$( ls ../../no_ionwater/*psf )
cat << EOF > analysis_without_h2o.tcl
source /home/aravinda1879/bash/namd/ana_namd/vmd_proc.tcl
source /home/aravinda1879/bash/namd/ana_namd/cross_cor.tcl
set mol [mol new "$file_psf" type psf waitfor all]
EOF
for file_dcd in $( ls ../../no_ionwater/*.dcd | sort --version-sort ) ; do

cat << EOF >> analysis_without_h2o.tcl 
mol addfile "$file_dcd" type dcd first 0 last -1 step 2  waitfor all molid \$mol
EOF
done
echo "**********************************"
echo "\n"
echo "please remove minimization dcd's"
echo "\n"
echo "**********************************"
