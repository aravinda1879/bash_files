#! /bin/bash
ls
#echo "enter the cordfile (name of pdb & psf) without extension"
infile0=$1
infile=${infile0}_20ps
insalt=$2
T=$3
cluster=$4
source ${HOME}/bash/namd/var_list_for_repeat_fileNames.sh
cat << EOF >> namd_variables.sh

#Computational resources
script=gpu  #options are cpu or gpu
num_nodes=2
num_gpu=1
num_cpu=512
num_gpu_cpu=7
run_repeat=10  #how many times needed to repeat bash run

#solvating variables (buffering distance needed with the water shell )
water_shell=no
shell_cut=7
buf_d=10
cubic_box=yes #yes or no
cubic_box_vec=80 # half of one needed (i.e. - for a box size with 140A give 70)  
cubic_box_vecz=\$(( cubic_box_vec + 20)) # half of one needed (i.e. - for a box size with 140A give 70)  
#simulation ions 
salt_con=${insalt}      
wrapWater=on
wrapAll=off 

metaDyn=no

#parameter file name                  IMPORTANT!!!

parm_lst=(  "par_all36_prot.prm" "par_all36_na.prm" "par_all36_carb.prm" "par_all36_cgenff.prm" "par_water_ions.prm")
#parm_lst=(  "par_all36_prot.prm" "par_all36_na.prm" "par_all36_carb.prm" "par_all36_cgenff.prm" "par_water_ions.prm" "par_all27_gfp_syg_impr_ai.inp" "ada_full.str" "in_pni.str" "CD-ini_connect_2.str" "pnipam_3.str")
#parm_lst=( \${parm_lst[@]} "lys_init_acr_psf.str" "pos_init_br.str" "pi.str" "common_lys_long_acr_psf.prm" "par_all35_ethers_oh.prm" "ma_mol_bb.str" "ma_ma_mabr.str" "ma_peg.str" "missing_par_ini_polma_psf.prm")
#parm_lst=( \${parm_lst[@]}  "par_all35_ethers_oh.prm" "top_all35_ethers_oh.rtf" "par_all35_ethers_oh.prm" "mal_ext.str" "ma_peg.str"  )

#minimizing variables
final_temp=${T}
first_time_step=0

#ff parameters
vdw_cutoff=9.0
switching=on   
vdwForceSwitching=on        
switchdist=7.0
pairlistdist=10.5

#MD run related
timestep=4
nonbondedFreq=1
fullElectFrequency=1
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
md_run0=1250000

#total run time
to_ns=000000
time_in_ns=200
run_time=\$(( time_in_ns / timestep ))\${to_ns}

EOF

