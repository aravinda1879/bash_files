#!/bin/bash
ls *pdb
#cpu1
echo "enter pdbname with extention"
read A
echo "$A"
echo "enter the box protien limit"
read bsize
echo "enter folder name"
read folder
dir_1=${folder}_tleap_${bsize}
mkdir $dir_1
cd ${dir_1}
B="${A}_1"
echo "$B"
infile="${A}"
########removing hydrogen
echo "check if hydrogens removed or not. If not remove them"
#########################
pdb4amber -i ../${infile} -o ${B} --reduce 
cat << EOF > tleap.in
source oldff/leaprc.ff14SB
loadamberparams frcmod.ionsjc_tip3p
mol = loadpdb $B
set default PBRadii mbondi2
charge mol
saveamberparm mol ${folder}_vac.prmtop ${folder}_vac.inpcrd
solvatebox mol TIP3PBOX $bsize
EOF
echo "do you want to neutralize the system?(y/n)"
read yn
if [ "$yn" = "y" ];
then
cat << EOF >> tleap.in
addIonsRand mol Na+ 0
addIonsRand mol Cl- 0
charge mol
EOF
fi
cat << EOF >> tleap.in
saveamberparm mol ${folder}_solvat.prmtop ${folder}_solvat.inpcrd
quit
EOF
tleap -f tleap.in
ambpdb -p ${folder}_solvat.prmtop < ${folder}_solvat.inpcrd > ${B}_final
rasmol ${B}_final
mkdir ../${folder}_run_${bsize}
cp ${folder}_solvat.prmtop ../${folder}_run_${bsize}/.
cp ${folder}_solvat.inpcrd ../${folder}_run_${bsize}/.
cd ../${folder}_run_${bsize}
source ~/bash/infile_prep.sh
echo "if want cpu script press y, for gpu script anything else"
read aa
if [ $aa = "y" ]; then
 source ~/bash/script.sh
else
 source ~/bash/script.sh
 source ~/bash/gpu_script.sh
 echo "GPU DONE!!!!!"
fi
echo "all parameters and toplogy files made for MMPBSA calculation"
echo "please make sure you have deleted ligans from the pdb" 
echo "vaccume pdb is with _1"
echo "5 input files were made"
echo "scrip file was made"
cd ..
echo "do you want to copy this to hpc press y"
read can
if [ $can = "y" ]; then  
scp -r ${folder}_run_${bsize} aravinda1879@gator.hpc.ufl.edu:/scratch/lfs/aravinda1879/. 
fi
