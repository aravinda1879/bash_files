#! /bin/bash
source ../namd_variables.sh
cat << EOF > script_gpu.sh
#!/bin/bash
#SBATCH --job-name=${infile}
#SBATCH --output=gpuMemTest.out
#SBATCH --error=gpuMemTest.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${num_gpu_cpu}
#SBATCH --ntasks-per-socket=1
#SBATCH --distribution=block:block
#SBATCH --time=7-00:00:00
#SBATCH --mem-per-cpu=1gb
#SBATCH --mail-type=none
#SBATCH --mail-user=some_user@some_domain.com
#SBATCH --qos=colina
#SBATCH --partition=gpu
#SBATCH --gres=gpu:${num_gpu}
#SBATCH --constrain=2080ti
module load cuda/10.0.130  intel/2018

namd2_dir="/blue/colina/aravinda1879/namd/NAMD_2.14_Linux-x86_64-verbs-smp-CUDA/namd2"
namd3_dir="/blue/colina/aravinda1879/namd/NAMD_3.0alpha6_Linux-x86_64-multicore-CUDA/namd3"


NAMD_NUM_PES=\$((\$SLURM_CPUS_PER_TASK ))
echo "NAMD_NUM_PES         = \$NAMD_NUM_PES"

PEMAP=\$(numactl --show | awk '/^physcpubind/ {for(i=2;i<NF;++i){printf "%d,",\$i}; {printf "%d",\$i}}')
echo "PEMAP                = \$PEMAP"


\${namd2_dir}  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP   ${conf_min1_f} > ${infile}_wb_min_1.log
\${namd2_dir}  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP   ${conf_min2_f} > ${infile}_wb_min_2.log
module load vmd
vmd -dispdev text -eofexit < $tcl_f4 > output_vmd5.log
\${namd3_dir}  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP    ${conf_heat_eq_f} > ${infile}_wb_eq_heat.log
\${namd3_dir}  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP    ${conf_pro_f} > ${infile}_wb_md1.log
EOF
for i in `seq 2 $run_repeat`;
do
cat << EOF >> script_gpu.sh
\${namd3_dir}  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP    ${conf_pro_f%1.conf}$i.conf > ${infile}_wb_md${i}.log
EOF
done    
cat << EOF >> script_gpu.sh
rm core*
EOF


