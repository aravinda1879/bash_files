#!/bin/bash
fmain=bR5k116   #parent file prefix which was used for smd
for i in `seq 1 10`;
do 
prefix=b5kR116imd${i}
mkdir ${prefix}
grep -E 'U1|CW' ${fmain}.pdb >  ${prefix}/${prefix}.pdb
grep -E 'U3|LIG' ${i}.pdb >> ${prefix}/${prefix}.pdb
cp ${fmain}.psf ${prefix}/${prefix}.psf
cd ${prefix}

#please change the parm list in the var file
bash ~/bash/amber/charmm_amber/var_list_for_repeat.sh ${prefix} 
source namd_variables.sh
bash ~/bash/amber/charmm_amber/namd_master_for_repeat.sh
#making amber HMR file
mkdir HMR_$prefix
cd HMR_$prefix
cp ../$dir3/${infile}_HMR_wb.prmtop .
cp ../$dir3/${infile}_HMR_wb.inpcrd .
source ~/bash/amber/charmm_amber/HMR_infile_prep.sh
source ~/bash/amber/charmm_amber/script.sh
source ~/bash/amber/charmm_amber/gpu_script.sh
cd ..
#making amber normal file
mkdir noHMR_$prefix
cd noHMR_$prefix
source ~/bash/amber/charmm_amber/infile_prep.sh
source ~/bash/amber/charmm_amber/script.sh
source ~/bash/amber/charmm_amber/gpu_script.sh
cd ..

#going back to the $prefix directory
cd ..
# cd to go back
cd ..
done
