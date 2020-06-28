#!/bin/bash
cat << EOF > _tleap1.in
source leaprc.ff14SB
loadamberparams frcmod.ionsjc_tip3p
rec = loadpdb $t8
set default PBRadii $radii
saveamberparm rec ${mrptop} _1inpcrd
quit
EOF

cat << EOF > _tleap2.in
source leaprc.ff14SB
loadamberparams frcmod.ionsjc_tip3p
com = loadpdb $t9
set default PBRadii ${radii}
saveamberparm com ${mcptop} _2incprd
quit
EOF
                                   
tleap -f _tleap1.in > _tleap1
tleap -f _tleap2.in > _tleap2

cat << EOF > _temp4.in
change AMBER_ATOM_TYPE @CB,CD,CD1,CD2,CG,CG1,CG2,CE C
outparm new${mrptop} 
EOF
cat << EOF > _temp5.in
change AMBER_ATOM_TYPE @CB,CD,CD1,CD2,CG,CG1,CG2,CE C
outparm new${mcptop} 
EOF
parmed.py -p ${mrptop} -i _temp4.in > _parm4
parmed.py -p ${mcptop} -i _temp5.in > _parm5

