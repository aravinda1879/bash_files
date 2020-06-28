echo "making the script file"
echo "please enter the following file names with extention"
echo "simulation name"
read name
pro=1
cat << EOF > script
#!/bin/bash
#SBATCH --job-name=$name
#SBATCH --output=rhodo-gpu.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --distribution=cyclic:cyclic
#SBATCH --extra-node-info=2:14:1
#SBATCH --time=7-12:00:00
#SBATCH --mem-per-cpu=3600
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aravinda1879@ufl.edu
##SBATCH --account=colina-b
##SBATCH --qos=colina-b
#SBATCH --partition=hpg2-gpu
#SBATCH --gres=gpu:tesla:1

module load intel/2016.0.109  openmpi/1.10.2
module load cuda/8.0
module load amber/16-cuda

EOF

if [ $pro = "1" ]; then
cat << EOF >> script
mpiexec  pmemd.cuda.MPI -O -i 3.in -o 3.out -p *top -c 2.rst -r 3.rst -x 3.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 4.in -o 4.out -p *top -c 3.rst -r 4.rst -x 4.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 5.in -o  5.out -p *top -c 4.rst -r 5.rst -x 5.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 6.in -o  6.out -p *top -c 5.rst -r 6.rst -x 6.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 7.in -o  7.out -p *top -c 6.rst -r 7.rst -x 7.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 8.in -o  8.out -p *top -c 7.rst -r 8.rst -x 8.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 9.in -o  9.out -p *top -c 8.rst -r 9.rst -x 9.nc -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 10.in -o  10.out -p *top -c 9.rst -r 10.rst -x 10.nc
mpiexec  pmemd.cuda.MPI -O -i 10.in -o  11.out -p *top -c 10.rst -r 11.rst -x 11.nc
mpiexec  pmemd.cuda.MPI -O -i 10.in -o  12.out -p *top -c 11.rst -r 12.rst -x 12.nc
EOF
else
cat << EOF >> script
mpiexec  pmemd.cuda.MPI -O -i 3.in -o 3.out -p *top -c 2.rst -r 3.rst -x 3.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 4.in -o 4.out -p *top -c 3.rst -r 4.rst -x 4.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 5.in -o  5.out -p *top -c 4.rst -r 5.rst -x 5.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 6.in -o  6.out -p *top -c 5.rst -r 6.rst -x 6.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 7.in -o  7.out -p *top -c 6.rst -r 7.rst -x 7.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 8.in -o  8.out -p *top -c 7.rst -r 8.rst -x 8.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 9.in -o  9.out -p *top -c 8.rst -r 9.rst -x 9.nc  -ref 2.rst
mpiexec  pmemd.cuda.MPI -O -i 10.in -o 10.out -p *top -c 9.rst -r 10.rst -x 10.nc 
EOF
fi

