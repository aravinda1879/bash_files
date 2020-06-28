#/bin/bash
source ~/bash/namd/charmm_lib.sh
echo "***********************"
echo "How many monomers?"
read mon_num
echo "output pdb name (without extensio)"
read fname2
fname=pol_${mon_num}.in
mon_sym="PEGM"

cat << EOF >  ${fname}
* make a PDB file out of a sequence
*
read rtf card name ${pol_rtf}
read param card name ${pol_prm}
read sequ card
${mon_num}
EOF

COUNTER=0
while [ ${COUNTER} -lt ${mon_num} ]; do
echo -n  "${mon_sym} " >> ${fname}
let COUNTER=COUNTER+1
done
echo "" >> ${fname}
cat << EOF >>  ${fname}
gene a setup first GCL0 last GCL3
ic param
ic seed 1 C1 1 O1 1 C2
ic build
hbuild
coor orient
write coor pdb name ${fname2}.pdb
* PDB file of custom sequence.
*
write psf card name ${fname2}.psf
* PSF
*
stop
EOF
charmm < ${fname}
