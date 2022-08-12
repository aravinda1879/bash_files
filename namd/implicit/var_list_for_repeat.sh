#! /bin/bash
ls
#echo "enter the cordfile (name of pdb & psf) without extension"
infile0=$1
salt=$2
T=$3
infile=${infile0}_10ps
cluster=$4
cat << EOF > namd_variables.sh
# common variables
export infile=${infile}
psf_f=${infile0}.psf
pdb_f=${infile0}.pdb
tcl_f0=bsa_25peg_solvation.tcl
tcl_f1=cell_vectors.tcl
tcl_f2=constrain_pdb.tcl
#(only for vacum)
tcl_f2_1=constrain_pdb_vac.tcl 
tcl_f3=neutralize.tcl
tcl_f4=bin2pdb.tcl
tcl_f5=smd_atm.tcl
tcl_f6=move_to_origin.tcl
tcl_f7=var_wat_cube.tcl
tcl_f8=var_wat_cube_add.tcl
tcl_f9=var_wat_cube_add_rmv_overlap.tcl
export conf_min1_f=${infile}_min_1.conf
export conf_min2_f=${infile}_min_2.conf
export conf_heat_eq_f=${infile}_heat_eq.conf
export conf_pro_f=${infile}_md1.conf

out_file_eq=${infile}_eq
out_file_pro=${infile}_md
# defining directories
dir2=project_prep_${infile}
dir3=project_run_${infile}

#Computational resources
script=gpu  #options are cpu or gpu
num_nodes=2
num_gpu=1
num_cpu=1024
num_gpu_cpu=14
run_repeat=1  #how many times needed to repeat bash run
#simulation ions 
wrapWater=off
wrapAll=off 


#parameter file name                  IMPORTANT!!!
parm_lst=(  "par_all36_prot.prm" "par_all36_na.prm" "par_all36_carb.prm" "par_all36_cgenff.prm" "par_water_ions.prm")
parm_lst=( \${parm_lst[@]} "lys_init_acr_psf.str" "pi.str" "common_lys_long_acr_psf.prm" "pos_init_br.str" "par_all36_cgenff_minBR.prm")
#parm_lst=( \${parm_lst[@]}  "par_all35_ethers_oh.prm" "top_all35_ethers_oh.rtf" "par_all35_ethers_oh.prm" "mal_ext.str" "ma_peg.str"  )

#minimizing variables
final_temp=${T}
first_time_step=0

#ff parameters
vdw_cutoff=10.0
switching=on
vdwForceSwitching=on        
switchdist=8
pairlistdist=12

#GBIS parameters
GBIS=on
ionConcentration=$salt
alphaCutoff=14
#hydrophobic energy
sasa=off
surfaceTension=0.006


#MD run related
timestep=2.0
nonbondedFreq=1
fullElectFrequency=2
stepsPerCycle=20

#temperature
langevin=on
langevinDamping=1
langevinHydrogen=off

# Pressure 
langevinPiston=on
langevinPistonTarget=1.01325
langevinPistonDecay=200
langevinPistonPeriod=100
            #group pressure yes for rigid bonds
useGroupPressure=yes 
            #flexible cell yes for membrane
useFlexibleCell=no
useConstantArea=no

# PME
Pme=no
PMEGridSpacing=1.0

#Constrain related
constraints=on
consref=restraint.pdb
conskfile=restraint.pdb
consref=restraint.pdb
conskfile=restraint.pdb
consref2=restraint2.pdb
conskfile2=restraint2.pdb
conskcol=B
constraintScaling=10

#fixed atoms
fixedAtoms=on
fixedAtomsForces=off
fixedAtomsFile=restraint.pdb
fixedAtomsCol=B


# Output format
restartfreq=5000 
dcdfreq=5000
xstFreq=5000
outputEnergies=5000
outputPressure=5000
outputTiming=5000

#Execution parameters
minimize=20000
heating_run=20000
equil_run=250000
md_run=25000000
md_run0=2500000

#total run time
to_ns=000000
time_in_ns=200
run_time=\$(( time_in_ns / 2 ))\${to_ns}

EOF
