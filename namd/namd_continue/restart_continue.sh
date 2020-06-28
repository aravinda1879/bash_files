#!/bin/bash
for i in `seq 5 10`;
do 
prefix=b10kRimd${i}
fname=${prefix}_5ps_wb
cd ${prefix}_5ps
mkdir continue_sim
cd continue_sim
#following only valid when minimization doesn't create restart file printing step is too big
md_files=$( ls ../restart_md/*.restart.coor -t )
md_files=($md_files)
len=${#md_files[@]}
cp ../restart_md/${md_files[0]%restart.coor}* .
rm *old
rm *xst
cp ../${fname}.p* .

cat ../script_cpu.sh | grep "#" > script_cpu.sh
cat ../script_gpu.sh | grep "#" > script_cpu.sh

cat < EOF >> script_cpu.sh
module load intel/2017.4.056
export HPC_OPENMPI_DIR=/apps/mpi/intel/2017.4.056/openmpi/2.0.3/el7
export HPC_OPENMPI_BIN=/apps/mpi/intel/2017.4.056/openmpi/2.0.3/el7/bin
export HPC_OPENMPI_LIB=/apps/mpi/intel/2017.4.056/openmpi/2.0.3/el7/lib64
export HPC_OPENMPI_INC=/apps/mpi/intel/2017.4.056/openmpi/2.0.3/el7/include
export PATH=\${HPC_OPENMPI_BIN}:\$PATH
export LD_LIBRARY_PATH=\${HPC_OPENMPI_LIB}:\$LD_LIBRARY_PATH
export PATH=/home/chasman/namd/2.12/src/Linux-x86_64-icc:\$PATH
EOF
cat < EOF >> script_gpu.sh
module load cuda/8.0 intel/2017  namd/2.12-cuda

NAMD_NUM_PES=\$((\$SLURM_CPUS_PER_TASK - 1))
echo "NAMD_NUM_PES         = \$NAMD_NUM_PES"

PEMAP=\$(numactl --show | awk '/^physcpubind/ {for(i=2;i<NF;++i){printf "%d,",\$i}; {printf "%d",\$i}}')
echo "PEMAP                = \$PEMAP"
EOF

for j in `seq $len $((len+4)) `;
do
cp ../conf_md/${fname}_md${j}.conf .
echo "srun --mpi=pmix namd2 +setcpuaffinity ${fname}_md${j}.conf > ${fname}_md${j}.log"  >> script_cpu.sh
echo "namd2  +p\${NAMD_NUM_PES} +idlepoll    +setcpuaffinity  +pemap \$PEMAP ${fname}_md${j}.conf > ${fname}_md${j}.log" >> script_gpu.sh
done


done
