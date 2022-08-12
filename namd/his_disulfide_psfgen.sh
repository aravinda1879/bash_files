#! /bin/bash
clear
echo "pdbname with the extention (edit the file if want mutations)"
echo "Also, change sement seperation script to chain or segmentg accrordingly "
#split first if you are using in case by case. (for polymer vacccine u set "no")
split_first=yes
ls *pdb
read name 
if [ $split_first == 'yes' ]; then 
    bash ~/bash/namd/split_pdb_seg.sh ${name} 
    infile_lst=`ls ${name//.pdb}_seg*pdb`
else
    infile_lst=`ls *pdb`
fi

for infile in ${infile_lst[@]}; do
    seg=`echo $infile | grep -Po "(?<=_seg).+(?=.pdb)"`
    echo "segment is $seg"
    outpdb=${infile//.pdb}_R.pdb  
    #temporory commented sionce fAb is already went through pdb4amber
    mkdir pdb4amber_files
    mv $infile pdb4amber_files/.
    cd pdb4amber_files 
    pdb4amber -i ${infile} --reduce --no-conect --add-missing-atoms -o $outpdb 
    if [ 1 == 0 ] ; then
    if [ "$seg" == "A" ] || [ "$seg" == "C" ] || [ "$seg" == "E" ] ; then 
    pdb4amber -i ${infile} --reduce --no-conect -m "83-ARG,84-SER,85-LYS,86-ALA,87-PHE,202-SER,204-ARG,205-ARG,206-SER,207-GLN,218-PRO,219-TRP,221-ARG,237-GLY,239-VAL" --add-missing-atoms  -o $outpdb 
    else
    pdb4amber -i ${infile} --reduce --no-conect --add-missing-atoms  -o $outpdb
    fi
    fi


cat << EOF > renum.tcl
mol load pdb ${outpdb}
set cnt 0
set infile [open  "${outpdb//.pdb}_renum.txt" r] 
while {[gets \$infile line]>=0} {
  set old_resid [lindex \$line 1]
  set new_resid [lindex \$line 3]
  set tsel [atomselect top "residue \$cnt"]
  #set tsel [atomselect top "resid \$new_resid"]
  \$tsel set resid \$old_resid
  \$tsel delete
  incr cnt 1
}
set all [atomselect top all]
\$all writepdb ../$outpdb
EOF
    vmd -dispdev text -eofexit < renum.tcl > renum.log 
    #mv $outpdb ../.
    cd ..
done

