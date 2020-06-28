#! /bin/bash
source ../namd_variables.sh
cat << EOF > $conf_heat_eq_f
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################
# Minimization and Equilibration in a Water Box

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################
structure          ${infile}_wb.psf
coordinates        ${infile}_wb.pdb
set temperature    $final_temp
set outputname     ${infile}_wb_eq
set previous_run   ${infile}_wb_min_2
set dir1           ../toppar
firsttimestep      0

###total patch grid = numcores+1
#twoAwayX yes
###PMEpencil**2 < 0.5*cores
#PMEPencils 4 

#############################################################
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


#Constant Temperature Control
langevin            ${langevin}    ;# do langevin dynamics
langevinDamping     ${langevinDamping}     ;# damping coefficient (gamma) of 1/ps
langevinTemp        \$temperature
langevinHydrogen    ${langevinHydrogen}    ;# dont couple langevin bath to hydrogens

wrapWater           $wrapWater              ;# wrap water to central cell
wrapAll             $wrapAll              ;# wrap other molecules too

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
EOF
grep '' _1.dat >> $conf_heat_eq_f
cat << EOF >>  $conf_heat_eq_f
# Contraining
constraints  $constraints 
consref      $consref2
conskfile    $conskfile2
conskcol     $conskcol
constraintScaling 10

# Output 
outputName         \$outputname

restartfreq         $restartfreq
dcdfreq             $dcdfreq
xstFreq             $xstFreq
outputEnergies      $outputEnergies
outputPressure      $outputPressure
outputTiming        $outputTiming

##### IF simulation is resuming edit following
#####
binCoordinates \${previous_run}.coor
extendedSystem \${previous_run}.xsc
#comment out the temperature if using following
binvelocities \${previous_run}.vel


#execution parameters 
#minimize            $minimize
reinitvels          0
######TEMP CONTROL
for {set i 0} {\$i <= \$temperature} {incr i 50} {
langevinTemp         \$i
run                  $heating_run
}
constraintScaling 0
run                 $equil_run

#
EOF

