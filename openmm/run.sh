source ../namd_variables.sh
cat << EOF > run
#!/bin/bash
export OPENMM_HOME=/usr/local/openmm-git
export OPENMM_LIB_DIR=\$OPENMM_HOME/lib
export OPENMM_PLUGIN_DIR=\$OPENMM_LIB_DIR/plugins
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\$OPENMM_LIB_DIR:\$OPENMM_PLUGIN_DIR
export OMP_NUM_THREADS=8
export OMP_STACKSIZE=10M
export OMP_SCHEDULE=static
export OMP_NESTED=false

mkdir -p scratch
/usr/bin/python < ./md.py
EOF
