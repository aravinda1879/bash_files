#! /bin/bash
source ../namd_variables.sh
cat << EOF > script_gpu.sh
#!/bin/bash
#SBATCH --job-name=${infile2}
#SBATCH --output=gpuMemTest.out
#SBATCH --error=gpuMemTest.err
#SBATCH --nodes=$num_nodes
#SBATCH --ntasks=$num_gpu_cpu
#SBATCH --cpus-per-task=1
##SBATCH --ntasks-per-socket=1
#SBATCH --distribution=block:block
#SBATCH --time=4-00:00:00
#SBATCH --mem-per-cpu=2gb
#SBATCH --mail-type=none
#SBATCH --mail-user=some_user@some_domain.com
##SBATCH --account=your_account
#SBATCH --qos=colina
#SBATCH --partition=gpu
#SBATCH --gres=gpu:tesla:${num_gpu}

module load intel cuda 
export NAMD_DIR=/home/aravinda1879/progs/NAMD_2.13_Linux-x86_64-verbs-smp-CUDA
export PATH=\$PATH:\$NAMD_DIR

export NODELIST=nodelist.\$SLURM_JOBID
echo "group main" > \$NODELIST
hostList=\$(srun /bin/hostname -s | sort -u)
for H in \$hostList
do
  echo "host \${H}-ib" >> \$NODELIST
done
cat \$NODELIST

#PEMAP="+pemap 1-6,8-13,15-20,22-27 +commap 0,7,14,21 +devices 0,1,2,3"
#PEMAP="+pemap 1-2,4-5,7-8,10-11,15-16,18-19,21-22,24-25 +commap 0,3,6,9,14,17,20,23 +devices 0,0,1,1,2,2,3,3"
PEMAP=\`numactl --show | awk '/^physcpubind/ {printf " +pemap %d",\$2; for(i=3;i<=NF;++i){printf ",%d",\$i}}'\`   #edited by me


export cores=$(($num_gpu_cpu - ($num_gpu * $num_nodes)))
export coresPerReplica=${coresPerReplica_gpu}
export replicas=\`echo "\$cores / \$coresPerReplica" | bc\`
for (( i = 0; i < \$replicas; i++ )); do mkdir -p output/\$i; done
EOF
for i in `seq 0 $run_repeat`;
do
cat << EOF >> script_gpu.sh
charmrun \${NAMD_DIR}/namd2 +replicas \$replicas +devicesperreplica $devicesperreplica  +ignoresharing +idlepoll ++p \$cores ++ppn  \$coresPerReplica  ++nodelist nodelist.\$SLURM_JOBID +setcpuaffinity \$PEMAP job${i}.conf +stdout output/%d/job${i}_%d.log
EOF
done    
cat << EOF >> script_gpu.sh
if [ -f nodelist.\$SLURM_JOBID ]; then
    rm nodelist.\$SLURM_JOBID
fi
EOF


