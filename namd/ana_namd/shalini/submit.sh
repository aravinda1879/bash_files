shopt -s extglob

prefix="1eo8"

#mod=mod
mod=wt
for i in `seq 1 1  `; do #1

#mod=${mod}${i}
mod=${mod}

#mkdir ${prefix}_${mod}$i
#pushd ${prefix}_${mod}$i
pushd ${prefix}_${mod}
mkdir temp2
#mv * temp2/.
mv temp/*pdb .
#cp ../renum_ha.tcl .
#sed -i "s/target/${prefix}_mod${i}/" renum_ha.tcl 
#sed -i "s/target/target.B99990001/" renum_ha.tcl 
#sed -i "s/kim_WT_noFold_renum/${prefix}_${mod}_noFold_renum/" renum_ha.tcl
#vmd -dispdev text -eofexit < renum_ha.tcl > renum.log

#cp ../chain_rename.tcl .
cp ../segname_rename.tcl .
sed -i "s/kim_K9_renum/${prefix}_${mod}_renum/" segname_rename.tcl
sleep 2
sed -i "s/kim_K9_segname/${prefix}_${mod}_noFold/" segname_rename.tcl
sleep 2
vmd -dispdev text -eofexit < segname_rename.tcl > segname_rename.log

#this may need a fix to avoid mut being moved
mkdir temp
#mv !(${prefix}_${mod}_noFold.pdb) temp/.


yes ${prefix}_${mod}_noFold.pdb | bash ~/bash/namd/his_disulfide_psfgen.sh 
#<<EOF
#bash ~/bash/namd/split_pdb_seg.sh ${prefix}_${mod}_noFold.pdb 

cp ../psfgen_template.tcl .
sed -i "s/H1_kim_WT/${prefix}_${mod}/g" psfgen_template.tcl
sed -i "s/temp_out_file/${prefix}_${mod}_noFold/" psfgen_template.tcl
vmd -dispdev text -eofexit < psfgen_template.tcl > psfgen.log

#mv !(${prefix}_${mod}_noFold.p*) temp/.
#mv temp/*mut .
#now make the tcl mut file for lysine sites
cp ../extract_lys_patch.tcl .
sed -i "s/infile/${prefix}_${mod}_noFold.pdb/g" extract_lys_patch.tcl
sed -i "s/out_file/residueID_C_mod0/" extract_lys_patch.tcl
vmd -dispdev text -eofexit < extract_lys_patch.tcl > extract_lys_patch.log

#you want to select if PEG or just the initiator 
cp ../psfgen_conjugate.tcl .
#sed -i "s/protein_input/${prefix}_${mod}_noFold/g" psfgen_conjugate.tcl
#sed -i "s/B 24/B 22/g" psfgen_conjugate.tcl
#sed -i "s/mutinfile/residueID_C_${mod}.mut/g" psfgen_conjugate.tcl
#sed -i "s/outconjufile/${prefix}_${mod}_noFold_conju/g" psfgen_conjugate.tcl
#sed -i "s/malfile/mal/g" psfgen_conjugate.tcl
#sed -i "s/malname/mal/g" psfgen_conjugate.tcl
#vmd -dispdev text -eofexit < psfgen_conjugate.tcl > psfgen_conju.log
#--------- for just init positive 
sed -i "s/protein_input/${prefix}_${mod}_noFold/g" psfgen_conjugate.tcl
sed -i "s/maleimide/positive_init\/init_br/g" psfgen_conjugate.tcl
sed -i "s/malfile/pos_init_br/g" psfgen_conjugate.tcl
sed -i "s/malname/PIT/g" psfgen_conjugate.tcl
sed -i "s/mutinfile/residueID_C_mod${i}.mut/g" psfgen_conjugate.tcl
sed -i "s/METMAL/KPINIT/g" psfgen_conjugate.tcl
sed -i "s/set chiral_list/#set chiral_list/g" psfgen_conjugate.tcl
sed -i "s/patch MALPEG/#patch MALPEG/g" psfgen_conjugate.tcl
sed -i "s/patch_end/#patch_end/g" psfgen_conjugate.tcl
sed -i "s/outconjufile/${prefix}_${mod}_noFold_conju/g" psfgen_conjugate.tcl
#vmd -dispdev text -eofexit < psfgen_conjugate.tcl > psfgen_conju.log
rm temp2 -r
#EOF
cp ../steps.sh . 
#sed -i "s/conju_in/${prefix}_${mod}_noFold_conju/g" steps.sh
sed -i "s/conju_in/${prefix}_${mod}_noFold/g" steps.sh
sed -i "s/btype/wb/g" steps.sh
bash steps.sh
#break
popd
done   #1
