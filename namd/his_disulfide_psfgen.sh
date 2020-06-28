#! /bin/bash
clear
echo "pdbname with the extention"
ls *pdb
read name
outpdb=${name//.pdb}_pdb4amb.pdb 
mkdir pdb4amber_files
mv $name pdb4amber_files/.
cd pdb4amber_files 
pdb4amber -i $name --reduce -o $outpdb --add-missing-atoms 
mv $outpdb ../.
python3 ~/bash/namd/run_with_bash_disul.py ${outpdb//.pdb}_
mv disul.temp ../.
echo "Done."
cd ..
