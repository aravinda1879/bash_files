#!/bin/bash
cat  << EOF > colvar_distance.conf
colvarsTrajFrequency    $colvarsTrajFrequency
colvarsRestartFrequency $colvarsRestartFrequency

colvar {
name r1
#lowerBoundary $lowerBoundary
UpperBoundary $UpperBoundary
width $width
outputAppliedForce $outputAppliedForce
distance {
group1 { 
# add all the atoms with occupancy 1 in the file atoms.pdb
atomsFile colvar.pdb
atomsCol O
atomsColValue 1.0
}
group2 { 
# add all the atoms with occupancy 1 in the file atoms.pdb
atomsFile colvar.pdb
atomsCol O
atomsColValue 2.0
}
}
}

metadynamics {
name metadyn_dist1
colvars r1
hillWeight $hillWeight # Default is 0.01 - higher numbers = faster
hillWidth $hillWidth
newHillFrequency 250 # Default is 100 - lower numbers = faster, updating every 1ps
}

harmonicWalls {
name wall_r
colvars r1
#lowerWalls $lowerWalls
#lowerWallConstant $lowerWallConstant
upperWalls $upperWalls
upperWallConstant $upperWallConstant
}

EOF
