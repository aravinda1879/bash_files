#!/bin/bash
echo "Check if dcd loading stride is good"
#echo "run this in the original dir. folder will be made"
mkdir no_ionwater
cd no_ionwater
#echo "vi ~/bash/namd/ana_md/remove_water_psf.sh"
#read dummy
for file in $( ls ../no_water/*psf ) ; do
file0=${file#../no_water/}
cat << EOF > remove_water_psf.tcl
set mol [mol new "$file" type psf waitfor all]
mol addfile "${file%.psf}.pdb" type pdb waitfor all molid \$mol
set solute [ atomselect top "all not water and not ion"]
\$solute writepsf "${file0%_wb.psf}_no_ionwater.psf"
EOF
vmd -dispdev text -eofexit < remove_water_psf.tcl > psf_removewater.log
#mv ${file%_wb.psf}_no_water.psf .
done
echo "done with removing water in psf"
for file1 in $( ls ../*dcd ) ; do
file2=${file1#../}
ofile2=${file2}
ofile2=no_ion_$ofile2
if [ "${file1##*_}" == "10ps" ]; then
ofile2=no_ion_no_water_10ps${file1##*10ps}
fi
cat << EOF > remove_water_${file2%.dcd}.tcl
set mol [mol new "$file" type psf waitfor all]
mol addfile "$file1" type dcd first 0 last -1 step 1 waitfor all molid \$mol
set solute [ atomselect top "all not water and not ion"]
animate write dcd $ofile2  beg 0 end -1 skip 0 waitfor all  sel \$solute
EOF
vmd -dispdev text -eofexit < remove_water_${file2%.dcd}.tcl > remove_water_${file2%.dcd}.log
echo "done with removing ion and water in $file2"
#rm ../no_water/$file1
done
echo "done with removing ion and water in everything"
mkdir tcl_log
mv *tcl tcl_log/.
mv *log tcl_log/.
echo "**********"
echo "**********"
echo "all the tcl files and log files were moved to  tcl_log dir."

