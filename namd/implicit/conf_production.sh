#! /bin/bash
source ../namd_variables.sh

cat << EOF > $conf_pro_f
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################
# Minimization and Equilibration in a Water Box

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################
structure          $psf_f
coordinates        $pdb_f
set temperature    $final_temp
set outputname     ${infile}_md1
set previous_run   ${infile}_eq.restart
set dir1           ../toppar
#firsttimestep      640000

if {1==1} {
proc get_first_ts { xscfile } {
set fd [open \$xscfile r]
gets \$fd
gets \$fd
gets \$fd line
set ts [lindex \$line 0]
close \$fd
return \$ts
}
set firsttime [get_first_ts \$previous_run.xsc]
firsttimestep \$firsttime
}

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


#GBIS parameters
GBIS             $GBIS
ionConcentration $ionConcentration
alphaCutoff      $alphaCutoff
#hydrophobic energy
sasa 		 $sasa
surfaceTension   $surfaceTension

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

#useGroupPressure   ${useGroupPressure} ;# needed for rigidBonds
#useFlexibleCell    ${useFlexibleCell} ;# may require in polymers
#useConstantArea    ${useConstantArea}

# PME
Pme                             $Pme
PMEGridSpacing                  $PMEGridSpacing
# Cell vectors


# fixd atoms 
fixedAtoms   	  $fixedAtoms
fixedAtomsForces  $fixedAtomsForces
fixedAtomsFile    $fixedAtomsFile
fixedAtomsCol     $fixedAtomsCol


#constraints 
#constraints  $constraints 
#consref      $consref
#conskfile    $conskfile
#conskcol     $conskcol
#constraintScaling 10

# Output 
outputName         \$outputname

restartfreq         $restartfreq
dcdfreq             $dcdfreq
#xstFreq             $xstFreq
outputEnergies      $outputEnergies
outputPressure      $outputPressure
outputTiming        $outputTiming

##### IF simulation is resuming edit following
#####
binCoordinates \${previous_run}.coor
#extendedSystem \${previous_run}.xsc
#comment out the temperature if using following
binvelocities \${previous_run}.vel


#execution parameters 
#minimize            $minimize
#reinitvels          0
######TEMP CONTROL
#for {set i 0} {$i <= $temperature} {incr i} {
#langevinTemp         $i
#run                  1000
#}
#constraintScaling 0
run                 $md_run0

#
EOF

