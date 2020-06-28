#!/bin/bash
echo "enter folder name"
read folder
mkdir ../${folder}_run_aNc
cd ../${folder}_run_aNc
source ~/bash/amber/charmm_amber/infile_prep.sh
echo "if want cpu script press y, for gpu script anything else"
read aa
if [ $aa = "y" ]; then
 source ~/bash/amber/charmm_amber/script.sh
else
 source ~/bash/amber/charmm_amber/script.sh
 source ~/bash/amber/charmm_amber/gpu_script.sh
 echo "GPU DONE!!!!!"
fi
#echo "all parameters and toplogy files made for MMPBSA calculation"
#echo "please make sure you have deleted ligans from the pdb" 
#echo "vaccume pdb is with _1"
echo "5 input files were made"
echo "scrip file was made"
cd ..
echo "do you want to copy this to hpc press y"
read can
if [ $can = "y" ]; then  
scp -r ${folder}_run_aNc aravinda1879@gator.hpc.ufl.edu:/scratch/lfs/aravinda1879/. 
fi
