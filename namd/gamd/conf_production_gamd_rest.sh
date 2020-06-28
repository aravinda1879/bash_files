# !/bin/bash
#echo "$j loop"
source ../../namd_variables.sh
imd=$1
cat << EOF > ${conf_pro_f//md1./gmd$(($j+1)).}
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################
# Minimization and Equilibration in a Water Box

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################
set dir0           ..
structure          \${dir0}/${infile}_wb.psf
coordinates        \${dir0}/${infile}_wb.pdb
set temperature    $final_temp
set dir1           \${dir0}/../toppar
#firsttimestep      640000

#if {1==1} {
proc get_first_ts { xscfile } {
set fd [open \$xscfile r]
gets \$fd
gets \$fd
gets \$fd line
set ts [lindex \$line 0]
close \$fd
return \$ts
}
#}

if { ([file exists ${infile}_wb_imd${imd}_gmd${j}.restart.xsc ] == 1) && ( [file exists ${infile}_wb_imd${imd}_rcmd${j}.restart.xsc ] == 0)   } {
set previous_run   ${infile}_wb_imd${imd}_gmd${j}.restart 
} elseif { [file exists ${infile}_wb_imd${imd}_rcmd${j}.restart.xsc ] == 1   } {
set previous_run   ${infile}_wb_imd${imd}_rcmd${j}.restart 
}
set firsttime [get_first_ts \${previous_run}.xsc]
firsttimestep \$firsttime

#twoAwayX yes
#PMEpencil**2 < 0.5*cores
#PMEPencils 4 
#

############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################
# Input
paraTypeCharmm        on
parameters          \$dir1/par_all35_ethers_oh.prm
parameters          \$dir1/par_all36m_prot.prm
parameters          \$dir1/par_all36_cgenff.prm
parameters          \$dir1/par_all36_na.prm
parameters          \$dir1/par_all36_carb.prm
parameters          \$dir1/par_all36_cgenff.prm
parameters          \$dir1/par_water_ions.prm

parameters          \$dir1/${linker_prm_file1}
parameters          \$dir1/${linker_prm_file2}
parameters          \$dir1/${linker_prm_file3}
parameters          \$dir1/${linker_prm_file4}
parameters          \$dir1/${linker_prm_file5}
parameters          \$dir1/${linker_prm_file6}
parameters          \$dir1/${linker_prm_file7}
#temperature is commented out only if using bin velocities.
#temperature         \$temperature

# Force-Field Parameters
exclude             scaled1-4
1-4scaling          1.0
cutoff              $vdw_cutoff
switching           $switching
switchdist          $switchdist
pairlistdist        $pairlistdist
vdwForceSwitching   $vdwForceSwitching

# Integrator Parameters
timestep            $timestep  ;# 2fs/step
rigidBonds          all  ;# needed for 2fs steps
nonbondedFreq       $nonbondedFreq
fullElectFrequency  $fullElectFrequency
stepspercycle       $stepsPerCycle

wrapWater           $wrapWater              ;# wrap water to central cell
wrapAll             $wrapAll              ;# wrap other molecules too

#Constant Temperature Control
langevin            ${langevin}    ;# do langevin dynamics
langevinDamping     ${langevinDamping}     ;# damping coefficient (gamma) of 1/ps
langevinTemp        \$temperature
langevinHydrogen    ${langevinHydrogen}    ;# dont couple langevin bath to hydrogens

#Pressure control --> commented out during heating and equillibration.
#langevinPiston                  $langevinPiston
#langevinPistonTarget            $langevinPistonTarget
#langevinPistonTemp              \$temperature
#langevinPistonDecay             $langevinPistonDecay
#langevinPistonPeriod            $langevinPistonPeriod

useGroupPressure   ${useGroupPressure} ;# needed for rigidBonds
useFlexibleCell    ${useFlexibleCell} ;# may require in polymers
useConstantArea    ${useConstantArea}

# PME
Pme                             $Pme
PMEGridSpacing                  $PMEGridSpacing

# Cell vectors


# Contraining
#constraints  $constraints 
#consref      $consref
#conskfile    $conskfile
#conskcol     $conskcol
#constraintScaling 10

#############################################################

if { \$firsttime < [ expr $run_time - $md_run ]  } { 
# Output to begin gamd
set outputname     ${infile}_wb_imd${imd}_gmd$(($j+1))
outputName         \$outputname

#loop for GAMD
accelMD               $accelMD
accelMDdual           $accelMDdual
accelMDdihe           $accelMDdihe
accelMDG              $accelMDG
accelMDGiE            $accelMDGiE
accelMDGRestart       on
accelMDGcMDSteps      0
accelMDGEquiSteps     0
accelMDGcMDPrepSteps  0
accelMDGEquiPrepSteps 0
accelMDOutFreq        $dcdfreq
accelMDGsigma0P       $accelMDGsigma0P
accelMDGsigma0D       $accelMDGsigma0D

#printing data
restartfreq         $restartfreq
dcdfreq             $dcdfreq
xstFreq             $xstFreq
outputEnergies      $outputEnergies
outputPressure      $outputPressure
outputTiming        $outputTiming

#restarting
binCoordinates        \${previous_run}.coor
extendedSystem        \${previous_run}.xsc
binvelocities  	      \${previous_run}.vel
accelMDGRestartFile   \${previous_run}.gamd

run                 $md_run

} elseif { ( \$firsttime >= [ expr $run_time - $md_run ] ) && ( \$firsttime  < [ expr $run_time ] ) } {
# Output to continue gamd
set outputname     ${infile}_wb_imd${imd}_gmd$(($j+1))
outputName         \$outputname

#loop for GAMD
accelMD               $accelMD
accelMDdual           $accelMDdual
accelMDdihe           $accelMDdihe
accelMDG              $accelMDG
accelMDGiE            $accelMDGiE
accelMDGRestart       on
accelMDGcMDSteps      0
accelMDGEquiSteps     0
accelMDGcMDPrepSteps  0
accelMDGEquiPrepSteps 0
accelMDOutFreq        $dcdfreq
accelMDGsigma0P       $accelMDGsigma0P
accelMDGsigma0D       $accelMDGsigma0D

#printing data
restartfreq         $restartfreq
dcdfreq             $dcdfreq
xstFreq             $xstFreq
outputEnergies      $outputEnergies
outputPressure      $outputPressure
outputTiming        $outputTiming

#restarting
binCoordinates        \${previous_run}.coor
extendedSystem        \${previous_run}.xsc
binvelocities  	      \${previous_run}.vel
accelMDGRestartFile   \${previous_run}.gamd

run                 [ expr $run_time - (\$firsttime )  ] 

} elseif { \$firsttime == [ expr $run_time ] } {

# Output to begin residence time calculation
set outputname      ${residence_infile}_wb_imd${imd}_rcmd$(($j+1))
outputName         \$outputname


#printing data
restartfreq         $residence_restartfreq
dcdfreq             $residence_dcdfreq
xstFreq             $residence_xstFreq
outputEnergies      $residence_outputEnergies
outputPressure      $residence_outputPressure
outputTiming        $residence_outputTiming

#restarting
binCoordinates      \${previous_run}.coor
extendedSystem      \${previous_run}.xsc
binvelocities       \${previous_run}.vel

run                 $residence_md_run

} elseif { \$firsttime  > [ expr $run_time ] && ( \$firsttime  < [ expr $run_time + $residence_md_run ] )  } {
# Output to continue residence time calculation
set outputname      ${residence_infile}_wb_imd${imd}_rcmd$(($j+1))
outputName         \$outputname


#printing data
restartfreq         $residence_restartfreq
dcdfreq             $residence_dcdfreq
xstFreq             $residence_xstFreq
outputEnergies      $residence_outputEnergies
outputPressure      $residence_outputPressure
outputTiming        $residence_outputTiming

#restarting
binCoordinates      \${previous_run}.coor
extendedSystem      \${previous_run}.xsc
binvelocities       \${previous_run}.vel

run                 [ expr $((run_time + residence_md_run)) - (\$firsttime )  ] 

} else {
quit 
}



#
EOF

