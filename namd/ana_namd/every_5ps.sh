#!/bin/bash
mkdir 5ps_traj
cd 5ps_traj
file=$( ls ../*psf )
for file1 in $( ls ../*dcd ) ; do
	file2=${file1#../}
	ofile21=${file2#*_wb}
	ofile3=${file2%_wb*}
	ofile4=${ofile3}_5ps_wb${ofile21}
cat << EOF > 5ps_${file2%.dcd}.tcl
set mol [mol new "$file" type psf waitfor all]
mol addfile "$file1" type dcd first 0 last -1 step 5 waitfor all molid \$mol
set solute [ atomselect top "all"]
animate write dcd $ofile4  beg 0 end -1 skip 0 waitfor all  sel \$solute
EOF
vmd -dispdev text -eofexit < 5ps_${file2%.dcd}.tcl > 5ps_${file2%.dcd}.log
echo "done with writing every 5  in $file2"
done
echo "done with writing every 5 everything"
