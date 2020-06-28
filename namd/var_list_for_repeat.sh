#! /bin/bash
ls
#echo "enter the cordfile (name of pdb & psf) without extension"
infile0=$1
infile=${infile0}_10ps
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

#Computational resources
script=gpu  #options are cpu or gpu
num_nodes=2
num_gpu=1
num_cpu=512
num_gpu_cpu=7
run_repeat=30  #how many times needed to repeat bash run
#simulation ions 
salt_con=${insalt}      
wrapWater=on
wrapAll=off 


#parameter file name                  IMPORTANT!!!
#linker_prm_file1=lys_init_acr_psf.str
#linker_prm_file2=pi.str
#linker_prm_file3=ma_ma_mabr.str
#linker_prm_file4=missing_par_ini_polma_psf.prm
#linker_prm_file5=ma_mol_bb.str
#linker_prm_file6=common_lys_long_acr_psf.prm
#linker_prm_file7=ma_peg.str



#linker_prm_file1=
#linker_prm_file2=
linker_prm_file1=par_all36_prot.prm                     
linker_prm_file2=par_all36_prot.prm                                      
linker_prm_file3=par_all36_prot.prm                   
#linker_prm_file4=toppar_all36_synthetic_polymer.str
linker_prm_file4=par_all36_carb.prm
linker_prm_file5=toppar_all36_carb_glycopeptide.str
#linker_prm_file6=toppar_water_ions.str                        
linker_prm_file6=fad.str 
linker_prm_file7=toppar_water_ions.str 
#solvating variables
buf_d=14
cubic_box=yes
cubic_box_vec=65 # half of one needed (i.e. - for a box size with 140A give 70)  

#minimizing variables
final_temp=${T}
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

#total run time
to_ns=000000
time_in_ns=300
run_time=\$(( time_in_ns / 2 ))\${to_ns}

EOF
