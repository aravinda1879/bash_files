shopt -s extglob

mod=mod
for i in `seq 0 0 `; do #1

#mkdir ${mod}$i
pushd 1eo8_${mod}$i
mkdir temp2
#mv * temp2/.
mv temp/*pdb .
#cp ../renum_ha.tcl .
#sed -i "s/target/1eo8_mod${i}/" renum_ha.tcl 
#sed -i "s/target/target.B99990001/" renum_ha.tcl 
#sed -i "s/kim_WT_noFold_renum/1eo8_${mod}${i}_noFold_renum/" renum_ha.tcl
#vmd -dispdev text -eofexit < renum_ha.tcl > renum.log

#cp ../chain_rename.tcl .
cp ../segname_rename.tcl .
sed -i "s/kim_K9_renum/1eo8_${mod}${i}_renum/" segname_rename.tcl
sleep 2
sed -i "s/kim_K9_segname/1eo8_${mod}${i}_noFold/" segname_rename.tcl
sleep 2
vmd -dispdev text -eofexit < segname_rename.tcl > segname_rename.log

#this may need a fix to avoid mut being moved
mkdir temp
mv !(1eo8_${mod}${i}_noFold.pdb) temp/.


#yes 1eo8_${mod}${i}_noFold.pdb | bash ~/bash/namd/his_disulfide_psfgen.sh 
bash ~/bash/namd/split_pdb_seg.sh 1eo8_${mod}${i}_noFold.pdb 

cp ../psfgen_template.tcl .
sed -i "s/H1_kim_WT/1eo8_${mod}${i}/g" psfgen_template.tcl
sed -i "s/temp_out_file/1eo8_${mod}${i}_noFold/" psfgen_template.tcl
vmd -dispdev text -eofexit < psfgen_template.tcl > psfgen.log

#mv !(1eo8_${mod}${i}_noFold.p*) temp/.
#mv temp/*mut .
#now make the tcl mut file for lysine sites
cp ../extract_lys_patch.tcl .
sed -i "s/infile/1eo8_${mod}${i}_noFold.pdb/g" extract_lys_patch.tcl
sed -i "s/out_file/residueID_C_mod0/" extract_lys_patch.tcl
vmd -dispdev text -eofexit < extract_lys_patch.tcl > extract_lys_patch.log

#you want to select if PEG or just the initiator 
cp ../psfgen_conjugate.tcl .
#sed -i "s/protein_input/1eo8_${mod}${i}_noFold/g" psfgen_conjugate.tcl
#sed -i "s/B 24/B 22/g" psfgen_conjugate.tcl
#sed -i "s/mutinfile/residueID_C_${mod}${i}.mut/g" psfgen_conjugate.tcl
#sed -i "s/outconjufile/1eo8_${mod}${i}_noFold_conju/g" psfgen_conjugate.tcl
#sed -i "s/malfile/mal/g" psfgen_conjugate.tcl
#sed -i "s/malname/mal/g" psfgen_conjugate.tcl
#vmd -dispdev text -eofexit < psfgen_conjugate.tcl > psfgen_conju.log
#--------- for just init positive 
sed -i "s/protein_input/1eo8_${mod}${i}_noFold/g" psfgen_conjugate.tcl
sed -i "s/maleimide/positive_init\/init_br/g" psfgen_conjugate.tcl
sed -i "s/malfile/pos_init_br/g" psfgen_conjugate.tcl
sed -i "s/malname/PIT/g" psfgen_conjugate.tcl
sed -i "s/mutinfile/residueID_C_mod${i}.mut/g" psfgen_conjugate.tcl
sed -i "s/METMAL/KPINIT/g" psfgen_conjugate.tcl
sed -i "s/set chiral_list/#set chiral_list/g" psfgen_conjugate.tcl
sed -i "s/patch MALPEG/#patch MALPEG/g" psfgen_conjugate.tcl
sed -i "s/patch_end/#patch_end/g" psfgen_conjugate.tcl
sed -i "s/outconjufile/1eo8_${mod}${i}_noFold_conju/g" psfgen_conjugate.tcl
vmd -dispdev text -eofexit < psfgen_conjugate.tcl > psfgen_conju.log
rm temp2 -r

cp ../steps.sh .
sed -i "s/conju_in/1eo8_${mod}${i}_noFold_conju/g" steps.sh
sed -i "s/btype/ws/g" steps.sh
bash steps.sh
#break
popd
done   #1
