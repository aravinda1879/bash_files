#! /bin/bash
source ../namd_variables.sh
cat << EOF > script_cpu.sh
#!/bin/bash
#SBATCH --job-name=${infile}
#SBATCH --output=cpu.out
#SBATCH --error=cpu.err
#SBATCH --ntasks=${num_cpu}
##SBATCH --nodes=$num_nodes
#SBATCH --cpus-per-task=1
##SBATCH --ntasks-per-socket=1
#SBATCH --distribution=cyclic:cyclic
#SBATCH --time=7-00:00:00
#SBATCH --mem-per-cpu=2gb
#SBATCH --mail-type=none
#SBATCH --partition=shared

#ml intel/2018  openmpi/3.1.2 namd/2.13
namd2_dir="/n/karplus_lab/aravinda1879/software/NAMD_2.14_Linux-x86_64-verbs"
#source ~/conda_list.sh 
#python3 /n/karplus_lab/aravinda1879/nodelist.py \$SLURM_NODELIST
echo "group main" > nodelist
for n in \`echo \$SLURM_NODELIST | scontrol show hostnames \`; do
 echo "host \$n" >> nodelist 
done 


\${namd2_dir}/charmrun ++nodelist nodelist  \${namd2_dir}/namd2 +isomalloc_sync +p${num_cpu}  ${conf_min1_f} > ${infile}_wb_min_1.log
\${namd2_dir}/charmrun ++nodelist nodelist  \${namd2_dir}/namd2 +isomalloc_sync   +p${num_cpu} ${conf_min2_f} > ${infile}_wb_min_2.log
module load vmd
vmd -dispdev text -eofexit < $tcl_f4 > output_vmd5.log
\${namd2_dir}/charmrun ++nodelist nodelist  \${namd2_dir}/namd2 +isomalloc_sync   +p${num_cpu} ${conf_heat_eq_f} > ${infile}_wb_eq_heat.log
\${namd2_dir}/charmrun ++nodelist nodelist  \${namd2_dir}/namd2 +isomalloc_sync   +p${num_cpu}  ${conf_pro_f} > ${infile}_wb_md.log
EOF
for i in `seq 2 $run_repeat`;
do
cat << EOF >> script_cpu.sh
\${namd2_dir}/charmrun ++nodelist nodelist  \${namd2_dir}/namd2 +isomalloc_sync    +p${num_cpu} ${conf_pro_f%1.conf}$i.conf > ${infile}_wb_md${i}.log
EOF
cat << EOF >> script_cpu.sh
EOF
done

