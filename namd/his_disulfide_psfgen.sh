#! /bin/bash
clear
echo "pdbname with the extention"
ls *pdb
read name 
bash ~/bash/namd/split_pdb_seg.sh ${name} 
infile_lst=`ls *_seg*pdb`
for infile in ${infile_lst[@]}; do
	seg=`pwd | grep -Po "(?<=_seg).+(?=.pdb)"`
	outpdb=${infile//.pdb}_p4b.pdb 
	mv $infile $outpdb
	#temporory commented sionce fAb is already went through pdb4amber
	#mkdir pdb4amber_files
	#mv $infile pdb4amber_files/.
	#cd pdb4amber_files 
	#pdb4amber -i ${infile} --reduce --no-conect  -o $outpdb  
	#mv $outpdb ../.
	#python3 ~/bash/namd/run_with_bash_disul.py ${outpdb//.pdb}_
        # no longer needed as I have added this to VMD
	#mv disul_seg$seg.temp ../.
	cd ..
done

