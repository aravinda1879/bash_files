#! /bin/bash
ls

echo "enter the cordfile (name of pdb & psf) without extension"
read infile0
infile=${infile0}
echo "enter the cordfile (name of coor & xsc) without extension"
read infile1
echo "enter a system name"
read infile2

cat << EOF > namd_variables.sh
# common variables
export infile=${infile}
export infile2=${infile2}
psf_f=${infile0}.psf
pdb_f=${infile0}.pdb
Bincoordinates=${infile1}.coor
extendedsystem=${infile1}.xsc


tcl_f2=constrain_pdb.tcl


# configuration for replica exchange scripts
rest2_sel="protein" #vmd selection for rest2
num_replicas=8
min_temp=310.5
max_temp=600
TEMP=310.15
#dcd_freq=\$steps_per_run * \$runs_per_frame]
steps_per_run=1000 #2ps with 2fs time step   energyuot = steps_per_run
num_runs=10000    # 20ns
# num_runs should be divisible by runs_per_frame * frames_per_restart = howOften restart tcl written
runs_per_frame=10
frames_per_restart=10
namd_config_file="common.conf" #normal MD parameters
output_root="output/%s/${infile2}" ; # directories must exist
# the following used only by show_replicas.vmd
psf_file=\$psf_f
initial_pdb_file=\$pdb_f
fit_pdb_file=\$pdb_f



########################
# defining directories
dir2=project_prep_${infile}
dir3=project_run_${infile}

#Computational resources
script=gpu  #options are cpu or gpu
num_nodes=2 #match for replicas=num_gpu*num_nodes
num_gpu=4 #max 4 for per node 
num_nodes_cpu=16
num_cpu=512
num_gpu_cpu=56
coresPerReplica_gpu=6      #(28*2-8)/8
run_repeat=12  #how many times needed to repeat bash run (each runs 20ns)
wrapWater=on
wrapAll=on
devicesperreplica=1

#parameter file name                  IMPORTANT!!!
linker_prm_file1=aclpl_aclpol_aclpolcl_psf_sma.prm
linker_prm_file2=common_lys_long_acr_psf.prm
linker_prm_file3=acl_pol_cl_psf_sma.prm
linker_prm_file4=missing_par_ini_pol_psf_sma.prm
linker_prm_file5=nterm_pol.prm


#for REST2
commotion=no
soluteScaling=on
soluteScalingCol=O
soluteScalingFile=scale_rst.spt
soluteScalingAll=off
soluteScalingFactor=0.9
soluteScalingFactorCharge=0.8
soluteScalingFactorVdw=0.7

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

EOF

