#!/bin/bash
echo "enter the ligand region eg:- 110-100,220-333"
read llist
echo "enter the receptor region"
read rlist
echo "enter a file name"
read fname
#name of the creating directory
wdir=be_1traj_$fname
mkdir $wdir
cd $wdir
cptop=_complex_strip_ion_wat.prmtop
lptop=_ligand_strip_ion_wat.prmtop
rptop=_receptor_strip_ion_wat.prmtop
radii=mbondi2
mlptop=_mutated_ligand_vac.prmtop
mcptop=_mutated_complex_vac.prmtop

export t1="_temp_complex.pdb"
export t2="_temp_mligand.pdb"
t2_2="mutated_protien.pdb"
t3="_mutated_ligand"
t4="_mutated_complex"
t5="_initial_complex"
t6="_mutated_complex.pdb"

ante-MMPBSA.py -p ../../*strip_h2o.prmtop -c ${cptop} -l ${lptop} -r ${rptop} -s :WAT,Cl-,Na+ -m :${rlist} --radii=${radii}

echo "Do you want to do a mutational analysis (y/n) ?"
read rpl_mut
#################### mutation loop begins
if [ $rpl_mut = "y" ] ; then
echo "Enter the complex region"
read clist
echo "enter the resid of mutating"
read resid
export resid=$resid
ls ../../*prmtop
echo "enter the original topology file name with ../../xxx"
read ogtop
ambpdb -p $ogtop < ../../*inpcrd > $t1
mkdir $t5
cd $t5
#making the complex 
cp ../$t1 .
pdb4amber -i $t1  -o t1 --dry   > _complex_pdb4amb
cp t1 ../$t1 
cd ..
#making the mutated  ligand
mkdir $t3
cd $t3
cp ../${t1} .
export llist=$llist
python2 ~/bash/ana_md/alanine_mutation.py 
pdb4amber -i ${t2_2}  -o ${t2}  --dry > _ligand_pdb4amb
cd ..
#making mutated complex pdb
mkdir $t4
cd $t4
cp ../$t1 .
temp=$llist
llist=$clist
export llist=$llist
python2 ~/bash/ana_md/alanine_mutation.py 
pdb4amber -i ${t2_2}  -o ${t6}   --dry > _complex_pdb4amb
llist=$temp
cd ..
cat << EOF > _tleap1.in
source leaprc.ff14SB
loadamberparams frcmod.ionsjc_tip3p
lig = loadpdb ${t3}/${t2}
set default PBRadii $radii
saveamberparm lig ${mlptop} _1
quit
EOF

cat << EOF > _tleap2.in
source leaprc.ff14SB
loadamberparams frcmod.ionsjc_tip3p
com = loadpdb ${t4}/${t6}
set default PBRadii $radii
saveamberparm com ${mcptop} _2
quit
EOF



tleap -f _tleap1.in > _tleap1
tleap -f _tleap2.in > _tleap2

cat << EOF > _temp4.in
change AMBER_ATOM_TYPE @CB,CD,CD1,CD2,CG,CG1,CG2,CE C
outparm new${mlptop} 
EOF
cat << EOF > _temp5.in
change AMBER_ATOM_TYPE @CB,CD,CD1,CD2,CG,CG1,CG2,CE C
outparm new${mcptop} 
EOF
parmed.py -p ${mlptop} -i _temp4.in > _parm4
parmed.py -p ${mcptop} -i _temp5.in > _parm5

fi
############################mutation loop ends

cat << EOF > _temp.in
change AMBER_ATOM_TYPE @CB,CD,CD1,CD2,CG,CG1,CG2,CE C
outparm new${cptop} 
EOF
cat << EOF > _temp2.in
change AMBER_ATOM_TYPE @CB,CD,CD1,CD2,CG,CG1,CG2,CE C
outparm new${lptop} 
EOF
cat << EOF > _temp3.in
change AMBER_ATOM_TYPE @CB,CD,CD1,CD2,CG,CG1,CG2,CE C
outparm new${rptop} 
EOF

parmed.py -p ${cptop} -i _temp.in > _parm1
parmed.py -p ${lptop} -i _temp2.in > _parm2
parmed.py -p ${rptop} -i _temp3.in > _parm3

source ~/bash/ana_md/mmpbsa_in_gen.sh
#echo "Do you want the binpos file y/n?"
#read rpl_bin
#if [ $rpl_bin = "y" ] ; then
cat << EOF > netcdf_strip_ion.trajin
parm ../prmtop/
trajin ../../combine_3_16_striph2o_5ps.nc
strip :Cl-,Na+
trajout 
run
EOF
#cpptraj -i mdcrdstrip_ion.trajin 
#fi

echo "Do you want the script (1) or command (2) ?"
read rep_scr
echo "enter the complex trajectory name (xxxx_5ps_strip_h2o_ion.nc)"
read nc_com

COUNTER=1
while [ $COUNTER -lt $((nround + 1 ))  ]; do
cd run_$COUNTER
source ~/bash/ana_md/mmpbsa_script_gen.sh
cd ..
let COUNTER=COUNTER+1
done
echo "DONE!!"

echo "Do you want to copy these files to gpu (y/n)"
read rep_copy
if [ $rep_copy = "y" ]; then
scp -r ../$wdir aravinda1879@gator.hpc.ufl.edu:/scratch/lfs/aravinda1879/3traj_be/.
echo "copied~!!"
fi
cd ..
#rm _* -r
