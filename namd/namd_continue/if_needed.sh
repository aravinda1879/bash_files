  1 #!/usr/bin/bash
  2 #SBATCH --mail-type=ALL
  3 #SBATCH --no-requeue
  4 #SBATCH --mem-per-cpu=500
  5 
  6 # restart_namd.sh
  7 
  8 # restart_namd.sh RESTART_TEMPLATE RESTART_TCL NRUNS
  9 
 10 sed -e "s:VAR_RESTART:${2}:" \
 11     -e "s:VAR_NRUNS:${3}:" \
 12     < $1 > restart.conf
 13 
 14 new_jobno=${2#*rest_sim.job}
 15 new_jobno=${new_jobno%%.*}
 16 new_jobno=$(($new_jobno + 1))
 17 
 18 : ${NAMDDIR="/n/home00/vzhao/opt/NAMD_2.14_Linux-x86_64-netlrts-smp-CUDA"}
 19 : ${GPU_PER_NODE:=1}
 20 
 21 echo $SLURM_JOB_NODELIST
 22 
 23 # echo "group main" > nodelist.$SLURM_JOBID
 24 # for n in `echo $SLURM_NODELIST | scontrol show hostnames`; do
 25 #   echo "host $n" >> nodelist.$SLURM_JOBID
 26 # done
 27 
 28 set -x
 29 NPROCPERREP=$(($SLURM_NTASKS / $SLURM_JOB_NUM_NODES / $GPU_PER_NODE))
 30 NREP=$(($SLURM_JOB_NUM_NODES * $GPU_PER_NODE))
 31 $NAMDDIR/charmrun ++n $NREP ++ppn $(($NPROCPERREP - 0)) ++mpiexec ++remote-shell srun $NAMDDIR/namd* +replicas $NREP +devicesperreplica 1 restart.conf +stdout outpu    t/%d/log_rest.%d.log




