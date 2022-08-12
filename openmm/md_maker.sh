source ../namd_variables.sh
cat << EOF > md.py
#!/usr/bin/python
from __future__ import print_function
import fileinput
import sys
#requires the file CHOMM.py, which is simple wrapper function to run MD using OpenMM using CHARMM parameters
#=====================================================================================
#
# aux parameters (e.g. they help define the required ones, but are not themselves used by CHOMM)
firstrun=0   ;# initial run index
numrun=$numrun
name ='${final_pdb_f%.pdb}'
#platformName='CPU' ; #optional; default is 'CUDA'
#==============================
# parameters required by CHOMM (some have default values)

psffile='${final_psf_f}' ;
pdbfile='${final_pdb_f}' ;
#topfile='./struc/'+name2+'36.top';
#paramfile='./struc/'+name2+'36.par';
toppar_dir="$top_dir"
paramfile_lst=[$(printf "'%s', " "${parm_lst[@]}" )];
paramfile = []
for pf in paramfile_lst:
 paramfile.append(f'{toppar_dir}/{pf}')

implicitSolvent=$implicitSolvent ;# run OBC2 implicit solvent simulation

#xscfile='.xsc' ;         # to obtain cell vectors from last line of xsc file
#boxfile='./struc/'+name+'.str'; # to obtain cell vectors from str file used in structure solvation

# to specify box manually (for PBC)
#dx=72 ;
#dy=72 ;
#dz=72 ;

hmass=4;       # amu, can use heavy hydrogens
friction=1   # 1/ps, thermostat coupling
dt=${timestep};          # timestep in fs
pmefreq=1;     # >1 requires multiple timestepping, which _dramatically_ slows down the code
cutoff=${vdw_cutoff};      # nonbonded cutoff
switchdist=$switchdist ; # (optional) switching distance

constraints=$constraints;   # harmonic positional restraints for equilibration
constraintscaling=1; # to scale hatmonic restraints uniformly
consfile="${consref}"; # as in NAMD/ACEMD, this file must have identical atom ordering to that in the system topology
conscol=1 ; # 1 beta ; 2 occupancy

shake=1; # whether to constrain bonds involving hydrogens

thermostat=1;  # whether to use a thermostat
temperature=${final_temp}; # kelvin
andersen=0;    # to use Andersen instead of Langevin ; (Note that I see energy up drifts quite often with andersen)
barostat=0;
pressure=1;    # units of atm
membrane_on=0; # whether to use a barostat for membrane simulations (z-axis is the membrane normal)
pme=0; # whether to use PME
pbc=0; # whether periodic boundary conditions are on

dynamo=$dynamo
dynamoTemplate='watershell.dyn'
watershell_restart='NONE'

mini=1;          # whether to minimize before dynamics
ministeps=$minimize;   # number of minimization iterations

numeq=$eq_run             # number of equilibration runs
numeqsteps=$heating_run; # number of equilibration steps
nummdsteps=$md_run; # number of production steps
#nummdsteps=20000
outputfreq=$outputTiming;  # frequency of generating output
dcdfreq=$dcdfreq;     # frequency of dcd output

flag='eq'
nsteps=numeqsteps;
#
if (firstrun==0):
 restart=0 ; # 0 -- start from PDB coordinates; 1 -- restart from native xml file
 restartfile=None ;
else:
 restart=1 ;
 if (firstrun>1):
  flag='md_20ps'
 restartfile='./'+name+str(firstrun-1)+flag+'.xml';
#restartfile= ;# to override
 xmlfile=restartfile ;        # to obtain cell vectors from xml file produced with OMM (default option if restart file is provided)
#
# run MD simulations with different parameters one after the other
#
irun=firstrun
while irun < firstrun + numrun :


 print(" =============================");
 print(" Run ", irun, "(will quit after", numrun-1,")");
# set some run-specific options
 constraintscaling = (5-1*irun)*0.1 ;# turn off gradually by run 10
 if irun >= numeq:
   flag='md_20ps'
   constraints=0 ;# to remove equilibration restraints
   nsteps=nummdsteps ;# increase number of steps
   hmass=4.0
   dt=4.0
   mini=0
   shake=1
   barostat=0 ;# turn off barostat
   pmefreq=1 ; # using MTS does not improve speed in my experience
#   cutoff=9 ;# to change cutoff
#
# dynamo section :
#
 watershell_output='watershell'+str(irun)+'.restart.txt'
 if (irun>0):
   watershell_restart='watershell'+str(irun-1)+'.restart.txt'
#
 dynamoConfig='watershell'+str(irun)+'.in'
# modify config template :
 df=open(dynamoTemplate,'r');
 dd=df.read()
 dd=dd.replace('@{restart_file}',watershell_restart)
 dd=dd.replace('@{output_file}',watershell_output)
 df=open(dynamoConfig,'w');
 df.write(dd);
 df.close();
 dynamoLog=dynamoConfig+'.log';
 outputName='./'+name+str(irun)+flag ;
 from os.path import expanduser
# sys.exit()
 exec(open(expanduser('CHOMM.py')).read())
# to do : check if run was successful, rerun if not
 irun=irun+1
 restartfile=outputName+'.xml'
 xmlfile=restartfile
 restart=1
EOF
