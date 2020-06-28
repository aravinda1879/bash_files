#!/bin/bash
ls *prmtop
echo  "write the system name for prmtop"
read name
cp *prmtop ${name}_solvate.prmtop
cat << EOF > prm_strip_h2o.trajin
parm *top
parmstrip :WAT
parmwrite out ${name}_strip_h2o.prmtop
EOF
cat << EOF > prm_strip_h2o_ion.trajin
parm *strip_h2o.prmtop
parmstrip :WAT,Cl-,Na+
parmwrite out ${name}_strip_h2o_ion.prmtop
EOF
cpptraj -i prm_strip_h2o.trajin
cpptraj -i prm_strip_h2o_ion.trajin
 
