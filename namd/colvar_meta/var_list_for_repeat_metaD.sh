#!/bin/bash
#source ${HOME}/bash/namd/var_list_for_repeat_fileNames.sh
cat << EOF >> namd_variables.sh
#solvation box size z direction 
cubic_box_vecz=\$(( cubic_box_vec + 20))

#distance colvar variables
atom_selection_grp1="xxxx"
atom_selection_grp2="yyyy"

lowerBoundary=0.0
UpperBoundary=15.0
width=0.05
outputAppliedForce=on

#metadynamics hill weight is the height of each hill in kcalmol-1
hillWeight=0.01
hillWidth=0.5

#harmonic well parameters
lowerWalls=0.0
lowerWallConstant=2.0
#7*0.05=0.35
upperWalls=14.0
upperWallConstant=2.0


colvarsTrajFrequency=5000
colvarsRestartFrequency=5000
EOF

