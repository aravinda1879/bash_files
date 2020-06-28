#! /bin/bash
source ../namd_variables.sh
cat << EOF > script_cpu.sh
#!/bin/bash
#SBATCH --job-name=${infile}
#SBATCH --output=gpuMemTest.out
#SBATCH --error=gpuMemTest.err
#SBATCH --ntasks=${num_cpu}
##SBATCH --nodes=$num_nodes
#SBATCH --cpus-per-task=1
##SBATCH --ntasks-per-socket=1
#SBATCH --distribution=cyclic:cyclic
#SBATCH --time=4-00:00:00
#SBATCH --mem-per-cpu=2gb
#SBATCH --mail-type=none
#SBATCH --mail-user=some_user@some_domain.com
##SBATCH --account=your_account
#SBATCH --qos=colina-b
#SBATCH --partition=hpg2-compute
##SBATCH --gres=gpu:tesla:${num_gpu}

#export PATH=/home/aravinda1879/progs/namd/2.12/Linux-x86_64-icc:\$PATH
ml intel/2018  openmpi/3.1.2 namd/2.13

srun --mpi=pmix_v2  namd2  ${conf_min1_f} > ${infile}_wb_min_1.log
srun --mpi=pmix_v2  namd2  ${conf_min2_f} > ${infile}_wb_min_2.log
module load vmd
vmd -dispdev text -eofexit < $tcl_f4 > output_vmd5.log
srun --mpi=pmix_v2  namd2   ${conf_heat_eq_f} > ${infile}_wb_eq_heat.log
srun --mpi=pmix_v2  namd2   ${conf_pro_f} > ${infile}_wb_md.log
EOF
for i in `seq 2 $run_repeat`;
do
cat << EOF >> script_cpu.sh
srun --mpi=pmix_v2  namd2   ${conf_pro_f%1.conf}$i.conf > ${infile}_wb_md${i}.log
EOF
done

