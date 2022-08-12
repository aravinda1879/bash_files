#! /bin/bash
source ../namd_variables.sh
cat << EOF > $conf_min1_f
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
set outputname     ${infile}_wb_min_1
set dir1           ../toppar
firsttimestep      $first_time_step

#twoAwayX yes
#PMEpencil**2 < 0.5*cores
#PMEPencils 4 
#

#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################
# Input
paraTypeCharmm        on
EOF

for par_file in ${parm_lst[@]}; do
cat << EOF >> $conf_min1_f
parameters          \$dir1/$par_file
EOF
done

cat << EOF >> $conf_min1_f
temperature         \$temperature

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

##### IF simulation is resuming edit following
#####
#binCoordinates \$inputname.restart.coor
#extendedSystem \$inputname.xsc
#comment out the temperature if using following
#binvelocities \$inputname.restart.vel
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
EOF
grep '' _1.dat >> $conf_min1_f
cat << EOF >> $conf_min1_f
# Contraining
constraints  $constraints 
consref      $consref
conskfile    $conskfile
conskcol     $conskcol
constraintScaling 500

# Output 
outputName         \$outputname

restartfreq         $restartfreq
dcdfreq             $dcdfreq
xstFreq             $xstFreq
outputEnergies      $outputEnergies
outputPressure      $outputPressure
outputTiming        $outputTiming

#execution parameters 
minimize            $minimize
#reinitvels          0
######TEMP CONTROL
#for {set i 0} {$i <= $temperature} {incr i} {
#langevinTemp         $i
#run                  1000
#}
#run                 1000000

#
EOF

