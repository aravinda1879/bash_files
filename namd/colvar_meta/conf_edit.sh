#!/bin/bash
colvar_file="colvar_distance.conf"
sed -i "s/binvelocities/#binvelocities/g" *md2.conf
sed -i "s/#temperature/temperature/g" *md2.conf
#sed -i '/stepspercycle/c\CUDASOAintegrate off' *md2.conf

for j in `seq 1 $run_repeat`; do #j+1 is what I have below. too lazy to change them. 

sed -i '/CUDASOAintegrate/c\#no CUDASOAintegrate for meta yet' ${conf_pro_f//md1./md$(($j+1)).} 
sed -i '/#constraints/c\colvars on'  ${conf_pro_f//md1./md$(($j+1)).}
sed -i "/#consref/c\colvarsConfig ${colvar_file}"  ${conf_pro_f//md1./md$(($j+1)).}
echo "${conf_pro_f//md1./md$(($j+1)).}"
if (( j > 1 )) ; then
# COMMENT OUT UNLEES YOU RESTART A JOB
sed -i "/#conskfile/c\colvarsInput \${previous_run}.colvars.state" ${conf_pro_f//md1./md$(($j+1)).} 
fi

done
echo "done updating metaD parameters in configuration files"



