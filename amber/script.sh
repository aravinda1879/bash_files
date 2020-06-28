cat << EOF > cpu_script
#!/bin/bash
#SBATCH --job-name=AM%j
#SBATCH -o job_%out1.out
#SBATCH -e job_%out1.err
##SBATCH --qos=colina-b
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<aravinda1879@chem.ufl.edu>
#SBATCH --nodes=2
#SBATCH --ntasks=32 
#SBATCH --mem-per-cpu=900mb
#SBATCH -t 200:00:00
module load intel/2017  openmpi/1.10.2 
module load amber/16
cd \$SLURM_SUBMIT_DIR

echo Host = \`hostname\`
echo Date = \`date\`

mpiexec sander.MPI -O -i 1.in -o  1.out -p *top -c *.inpcrd -r 1.rst   -ref *.inpcrd
mpiexec sander.MPI -O -i 2.in -o  2.out -p *top -c 1.rst -r 2.rst -ref *.inpcrd
EOF
