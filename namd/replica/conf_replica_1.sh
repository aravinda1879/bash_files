#! /bin/bash
source ../namd_variables.sh

cat << EOF > common.conf
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################
# Minimization and Equilibration in a Water Box

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################
structure          ${psf_f}
coordinates        ${pdb_f}

set temperature    $TEMP
#set outputname     ${infile}_wb_md1
#set previous_run   ${infile}
set dir1           ../../toppar
#since inside the replica folder
#firsttimestep      640000

##### IF simulation is resuming edit following
binCoordinates ${Bincoordinates}
extendedSystem ${extendedsystem}


#if {1==1} {
#proc get_first_ts { xscfile } {
#set fd [open \$xscfile r]
#gets \$fd
#gets \$fd
#gets \$fd line
#set ts [lindex \$line 0]
#close \$fd
#return \$ts
#}
#set firsttime [get_first_ts \$previous_run.xsc]
#firsttimestep \$firsttime
#}

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
vdwForceSwitching   $vdwForceSwitching
switchdist          $switchdist
pairlistdist        $pairlistdist

# Integrator Parameters
timestep            $timestep  ;# 2fs/step
rigidBonds          all  ;# needed for 2fs steps
nonbondedFreq       $nonbondedFreq
fullElectFrequency  $fullElectFrequency
stepspercycle       $stepsPerCycle

# wrapWater           $wrapWater              ;# wrap water to central cell
wrapAll             $wrapAll              ;# wrap other molecules too

#Constant Temperature Control
langevin            ${langevin}    ;# do langevin dynamics
langevinDamping     ${langevinDamping}     ;# damping coefficient (gamma) of 1/ps
#langevinTemp        \$temperature
langevinHydrogen    ${langevinHydrogen}    ;# dont couple langevin bath to hydrogens

#Pressure control --> commented out during heating and equillibration.
langevinPiston                  $langevinPiston
langevinPistonTarget            $langevinPistonTarget
langevinPistonTemp              \$temperature # multiple definitions of this. worked when commented
langevinPistonDecay             $langevinPistonDecay
langevinPistonPeriod            $langevinPistonPeriod

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

# Output 
#outputName         \$outputname

#restartfreq         $restartfreq
#dcdfreq             $dcdfreq
#xstFreq             $xstFreq
#outputEnergies      $outputEnergies
#outputPressure      $outputPressure
#outputTiming        $outputTiming



#execution parameters 
#minimize            $minimize
#reinitvels          0
######TEMP CONTROL
#for {set i 0} {$i <= $temperature} {incr i} {
#langevinTemp         $i
#run                  1000
#}
#constraintScaling 0
#run                 $md_run
#

commotion             $commotion

soluteScaling           $soluteScaling
soluteScalingCol        $soluteScalingCol
soluteScalingFile       $soluteScalingFile

soluteScalingAll $soluteScalingAll
soluteScalingFactor         $soluteScalingFactor
soluteScalingFactorCharge   $soluteScalingFactorCharge
soluteScalingFactorVdw      $soluteScalingFactorVdw


EOF

