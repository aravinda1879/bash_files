#! /bin/bash
ls
#echo "enter the cordfile (name of pdb & psf) without extension"
infile0=$1
infile=${infile0}_20ps
insalt=$2
T=$3
cluster=$4
cat << EOF > namd_variables.sh
#inputs for
cluster=$4
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
export conf_min1_f=${infile}_wb_min_1.conf
export conf_min2_f=${infile}_wb_min_2.conf
export conf_heat_eq_f=${infile}_wb_heat_eq.conf
export conf_pro_f=${infile}_wb_md1.conf

out_file_eq=${infile}_wb_eq
out_file_pro=${infile}_wb_md
# defining directories
dir2=project_prep_${infile}
dir3=project_run_${infile}

#top_dir="/home/am1879/github_projects/toppar"
top_dir="/n/karplus_lab/aravinda1879/namd/toppar"
final_psf_f=${infile}_boxtype.psf
final_pdb_f=${infile}_boxtype.pdb


#Computational resources
script=gpu  #options are cpu or gpu
num_nodes=2
num_gpu=1
num_cpu=512
num_gpu_cpu=8
run_repeat=30  #how many times needed to repeat bash run

#solvating variables (buffering distance needed with the water shell )
implicitSolvent=0
water_shell=yes
dynamo=1
cubic_box=no 
shell_cut=7

buf_d=10
cubic_box_vec=85 # half of one needed (i.e. - for a box size with 140A give 70)  

#simulation ions 
salt_con=${insalt}      
wrapWater=on
wrapAll=off 


#parameter file name                  IMPORTANT!!!

parm_lst=(  "par_all36_prot.prm" "par_all36_na.prm" "par_all36_carb.prm" "par_all36_cgenff.prm" "par_water_ions.prm")
#parm_lst=( \${parm_lst[@]} "lys_init_acr_psf.str" "pi.str" "common_lys_long_acr_psf.prm" "pos_init_br.str"  )
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
constraints=1     #used on in namd
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
#to_ns=000000
to_ns=000000
md_run_percycle=25   #enter in ns
md_run_percycle=\${md_run_percycle}\${to_ns}   


minimize=10000
heating_run=20000
equil_run=250000 # not needed
md_run=\$(( md_run_percycle / timestep ))


eq_run=5
mdcyles=10
numrun=\$(( eq_run + mdcyles  ))

#total run time
#time_in_ns=220
#run_time=\$(( time_in_ns / 4 ))\${to_ns}

EOF
