#!/bin/bash

rep_mut="y"
rep_scr="1"
comdir="../../allnc"
if [ $rep_scr = "1" ]; then 
cat << EOF > script_$COUNTER
#!/bin/bash
#
#PBS -N be_${fname}_run_$COUNTER
#PBS -M aravinda1879@ufl.edu
#PBS -m abe
#PBS -o amber.out
#PBS -e amber.err
#PBS -j oe
#PBS -l nodes=1:ppn=8
#PBS -l walltime=100:00:00
#PBS -l pmem=3gb


module load intel/2013  openmpi/1.6.5
module load amber/14

echo \$PBS_O_WORKDIR
cd \$PBS_O_WORKDIR

echo Host = \`hostname\`
echo Date = \`date\`

EOF
if [ ${rep_mut} == "y" ]; then 

cat << EOF >> script_${COUNTER}
mpiexec  MMPBSA.py.MPI -O -i mmpbsa_${COUNTER}.in  -o final_be_${COUNTER}.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -mc ../new$mcptop  -ml ../new$mlptop  -y ${comdir}/${nc_com}_5ps_strip_h2o_ion.mdcrd > progress_${COUNTER}.log 2>&1 
EOF
else
cat << EOF >> script_${COUNTER}
mpiexec  MMPBSA.py.MPI -O -i mmpbsa_${COUNTER}.in  -o final_be_${COUNTER}.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -y /scratch/aravinda1879/o_r_run_solv_10/combined_all_striph20_mdcrd2binpos.binpos  > progress_${COUNTER}.log 2>&1 
EOF
fi
cat << EOF >> ../run_list.sh
cd run_${COUNTER}
qsub script_${COUNTER}
cd ..
EOF

#command script 
else
if [ ${rep_mut} == "y" ]; then 
cat << EOF > command_${COUNTER}
cat << EOF > command_${COUNTER}
nohup MMPBSA.py -O -i mmpbsa_${COUNTER}.in  -o final_be_${COUNTER}.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -y /scratch/aravinda1879/o_r_run_solv_10/combined_all_striph20_mdcrd2binpos.binpos  > progress_${COUNTER}.log 2>&1 &
EOF
else
cat << EOF > command_${COUNTER}
nohup MMPBSA.py -O -i mmpbsa_${COUNTER}.in  -o final_be_${COUNTER}.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -y /scratch/aravinda1879/o_r_run_solv_10/combined_all_striph20_mdcrd2binpos.binpos  > progress_${COUNTER}.log 2>&1 &
EOF
fi
cat << EOF >> ../run_list.sh
cd run_${COUNTER}
source command_${COUNTER}
cd ..
EOF
fi
