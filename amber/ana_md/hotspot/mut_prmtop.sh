#!/bin/bash
source ${wdir}/var_list.sh
pdb4amber -i ${t2_2}  -o ${t6}  --dry > log_complex_pdb4amb

