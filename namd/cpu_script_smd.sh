#! /bin/bash
source ../namd_variables.sh
cat << EOF > script_cpu.sh
#!/bin/bash
#SBATCH --job-name=${infile}
#SBATCH --output=gpuMemTest.out
#SBATCH --error=gpuMemTest.err
#SBATCH --ntasks=${num_cpu}
#SBATCH --nodes=$nodes
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-socket=
#SBATCH --distribution=cyclic:cyclic
#SBATCH --time=7-12:00:00
#SBATCH --mem-per-cpu=1000
#SBATCH --mail-type=ALL
#SBATCH --mail-user=some_user@some_domain.com
##SBATCH --account=your_account
##SBATCH --qos=colina
#SBATCH --partition=hpg2-compute
##SBATCH --gres=gpu:tesla:${num_gpu}
module load intel/2017.1.132  openmpi/2.0.1 namd/2.12

mpiexec -n ${num_cpu} namd2  ${conf_pro_f} > ${infile}_wb_smd_md.log
EOF

