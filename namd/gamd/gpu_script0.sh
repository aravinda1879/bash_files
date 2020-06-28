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
##SBATCH --account=your_account
#SBATCH --qos=colina
#SBATCH --partition=gpu
#SBATCH --gres=gpu:${num_gpu}
#SBATCH --constrain=2080ti
module load cuda/10.0.130  intel/2018  namd/2.13

NAMD_NUM_PES=\$((\$SLURM_CPUS_PER_TASK ))
echo "NAMD_NUM_PES         = \$NAMD_NUM_PES"

PEMAP=\$(numactl --show | awk '/^physcpubind/ {for(i=2;i<NF;++i){printf "%d,",\$i}; {printf "%d",\$i}}')
echo "PEMAP                = \$PEMAP"


namd2  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP   ${conf_min1_f} > ${infile}_wb_min_1.log
namd2  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP   ${conf_min2_f} > ${infile}_wb_min_2.log
module load vmd
vmd -dispdev text -eofexit < $tcl_f4 > output_vmd5.log
namd2  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP    ${conf_heat_eq_f} > ${infile}_wb_eq_heat.log
namd2  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP    ${conf_pro_f} > ${infile}_wb_md1.log
namd2  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP  ${conf_pro_f%md1.conf}gmd0.conf > ${infile}_wb_gmd0.log
for i in \`seq 1 3\`;
do
cd imd_\${i}
if [ \$i == "1" ]; then
jid1=\$(sbatch script_gpu.sh)
else
jid1=\$(sbatch --dependency=afterany:\${jid1##* }  script_gpu.sh)
fi 
cd ../
done
rm core*
EOF



