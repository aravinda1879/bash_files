#! /bin/bash
source ../namd_variables.sh
cat << EOF > script_cpu.sh
#!/bin/bash
#SBATCH --job-name=${infile}
#SBATCH --output=gpuMemTest.out
#SBATCH --error=gpuMemTest.err
#SBATCH --ntasks=${num_cpu}
#SBATCH --nodes=${num_nodes_cpu}
#SBATCH --cpus-per-task=1
##SBATCH --ntasks-per-socket=1
#SBATCH --distribution=cyclic:cyclic
#SBATCH --time=4-00:00:00
#SBATCH --mem-per-cpu=2gb
#SBATCH --mail-type=none
#SBATCH --mail-user=some_user@some_domain.com
##SBATCH --account=your_account
##SBATCH --qos=colina-b
#SBATCH --partition=hpg2-compute
##SBATCH --gres=gpu:tesla:${num_gpu}

#module load intel/2017  openmpi/2.0.1
#export PATH=/apps/intel/2017.1.132/namd/2.12/Linux-x86_64-icc:\$PATH
module load intel/2018  openmpi/3.1.2 namd/2.13

export replicas=$num_replicas
for (( i = 0; i < \$replicas; i++ )); do mkdir -p output/\$i; done

EOF
for i in `seq 0 $run_repeat`;
do
cat << EOF >> script_cpu.sh
srun --mpi=pmix  namd2 +replicas $replicas +setcpuaffinity job${i}.conf +stdout output/%d/job${i}_%d.log
EOF
done    
