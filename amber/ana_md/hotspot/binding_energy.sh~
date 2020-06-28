#!/bin/bash
source var_list.sh

#name of the creating directory
w2dir=be_1traj_$fname
mkdir $w2dir
cd $w2dir

ante-MMPBSA.py -p ../../*strip_h2o.prmtop -c ${cptop} -l ${lptop} -r ${rptop} -s :WAT,Cl-,Na+ -m :${rlist} --radii=${radii}
############################# mutation loop start
ambpdb -p $ogtop < ../../*inpcrd > $t1
mkdir _d1
cd _d1
mv ../$t1 t0
pdb4amber -i t0 -o ${t1} --dry
mv ${t1} ../.
cd ..
###Complex mutation
temp=$llist
export llist=$clist
python2 ~/bash/ana_md/hotspot/mut_complex.py 
llist=$temp

###Receptor mutation
temp=$llist
export llist=$rlist
python2 ~/bash/ana_md/hotspot/mut_receptor.py
llist=$temp

###Making prmtop
python2 ~/bash/ana_md/hotspot/prmtop_prep.py
############################# mutation loop end

############################# Wild type parmtop prep start
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
############################# Wild type parmtop prep end

rm _*
rm */_*

