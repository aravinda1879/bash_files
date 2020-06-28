
cat << EOF > cpu_script
#!/bin/bash
#
#PBS -N $folder
#PBS -M aravinda1879@ufl.edu
#PBS -m abe
#PBS -o amber.out
#PBS -e amber.err
#PBS -j oe
#PBS -l nodes=1:ppn=16
#PBS -l walltime=30:00:00
#PBS -l pmem=1000mb

module load intel/2013  openmpi/1.6.5
module load amber/14
echo \$PBS_O_WORKDIR
cd \$PBS_O_WORKDIR

echo Host = \`hostname\`
echo Date = \`date\`

mpiexec sander.MPI -O -i 1.in -o  1.out -p *top -c *.inpcrd -r 1.rst   -ref *.inpcrd
mpiexec sander.MPI -O -i 2.in -o  2.out -p *top -c 1.rst -r 2.rst -ref *.inpcrd
qsub script
EOF
