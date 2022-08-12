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
#SBATCH --time=1-08:00:00
##SBATCH --mem-per-cpu=1gb
#SBATCH --mem=10gb
#SBATCH --mail-type=none
#SBATCH --partition=gpu
#SBATCH --gres=gpu:${num_gpu}
##SBATCH --constrain=2080ti

module purge
source /n/karplus_lab/aravinda1879/software/set-up-wshell_c11/load_module.sh

export ROOT=/n/karplus_lab/aravinda1879/software/set-up-wshell_c11

export OPENMM_HOME=\$ROOT/openmm/build
export DYNAMO_LIB_DIR=\$ROOT/victor/lib
export OPENMM_LIB_DIR=\$OPENMM_HOME/lib
export OPENMM_PLUGIN_DIR=\$OPENMM_LIB_DIR/plugins
export LD_LIBRARY_PATH=\$OPENMM_LIB_DIR:\$OPENMM_PLUGIN_DIR:\$DYNAMO_LIB_DIR:\$LD_LIBRARY_PATH:

PYTHON_LOCAL=\$ROOT/openmm/build/python/build/lib.linux-x86_64-3.8:\$ROOT/victor/plugin_master/openmm-dynamo/build/python/build/lib.linux-x86_64-3.8
export PYTHONPATH=\$PYTHON_LOCAL:\$PYTHON_LOCAL

export OMP_NUM_THREADS=\$SLURM_CPUS_PER_TASK 
export OMP_STACKSIZE=10M
export OMP_SCHEDULE=static
export OMP_NESTED=false

#\${HOME}/.conda/envs/openmm_py3/bin/python md.py > md.log 
\${HOME}/.conda/envs/tf2.5_cuda11/bin/python md.py > md.log 

EOF
