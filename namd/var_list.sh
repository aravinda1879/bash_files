#! /bin/bash
ls
echo "enter the cordfile (name of pdb & psf) without extension"
read infile0
infile=${infile0}_5ps
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
export conf_min1_f=${infile}_wb_min_1.conf
export conf_min2_f=${infile}_wb_min_2.conf
export conf_heat_eq_f=${infile}_wb_heat_eq.conf
export conf_pro_f=${infile}_wb_md1.conf

out_file_eq=${infile}_wb_eq
out_file_pro=${infile}_wb_md
# defining directories
dir2=project_prep_${infile}
dir3=project_run_${infile}

#Computational resources
script=gpu  #options are cpu or gpu
num_nodes=1
num_gpu=2
num_cpu=256
num_gpu_cpu=28
run_repeat=12  #how many times needed to repeat bash run
#simulation ions 
salt_con=0.15      
wrapWater=on
wrapAll=on


#parameter file name                  IMPORTANT!!!
linker_prm_file1=link.prm
linker_prm_file2=link_analog.prm
linker_prm_file3=lys_complete_updated.prm
linker_prm_file4=lys_complete_updated.prm
linker_prm_file5=lys_complete_updated.prm

#solvating variables
buf_d=14

#minimizing variables
final_temp=300
first_time_step=0

#ff parameters
vdw_cutoff=12.0
switching=on   
vdwForceSwitching=on        
switchdist=10.0
pairlistdist=13.5

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
Pme=on
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



# Output format
restartfreq=5000 
dcdfreq=5000
xstFreq=5000
outputEnergies=5000
outputPressure=5000
outputTiming=5000

#Execution parameters
minimize=10000
heating_run=20000
equil_run=250000
md_run=25000000
md_run0=2500000

EOF

