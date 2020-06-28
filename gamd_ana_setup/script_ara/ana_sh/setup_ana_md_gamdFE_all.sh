#!/bin/bash
wd_ana=gamdFE_all
current_folder=`pwd`
<<COMMENT1
Run this after running gamdFE. DO NOT RUN TOGETHER. IT will work. but redundand. Since purpose of thjis is to combine all and make one plot.
and make sure sub umd folders are not passed through submit script. All the data will be in primary ana_gamd folder
COMMENT1
export PYTHONPATH=""
file_list=( "$@" )
dir_py="/home/${USER}/bash/namd/ana_namd/gamd_ana"

for file in ${file_list[@]} ; do

cd $file
mkdir ana_gamd
cd ana_gamd
temp=310.5
ana_types=( "rg" "e2e" )
fnames=( "rg_B_polymer" "com_B_c2_c2"  )

min=0
max=0
num_bin=50
rm *.dat
rm *.log
rm *.dat*

bin_size_lst=()
for ((i=0;i<${#ana_types[@]};++i)); do
rm  ${fnames[i]}_4gamdFE_all.dat

grep "" ../ana_md/gamdFE/weights.dat > weights_all.dat 
outfile=( ${outfile[@]}  ${fnames[i]}_4gamdFE_all)
grep "" ../ana_md/gamdFE/${fnames[i]}_4gamdFE.dat > ${outfile[i]}.dat


for j in `seq 1 3`; do
grep "" ../imd_${j}/ana_md/gamdFE/weights.dat >> weights_all.dat
grep "" ../imd_${j}/ana_md/gamdFE/${fnames[i]}_4gamdFE.dat >> ${outfile[i]}.dat
done

min=`awk 'BEGIN{a=10000000}{if ($1<0+a) a=$1} END{print a}' ${outfile[i]}.dat`
max=`awk 'BEGIN{a=   0}{if ($1>0+a) a=$1} END{print a}' ${outfile[i]}.dat`
bin_size=`awk "BEGIN {print (${max} -  ${min})/$num_bin }"`
bin_size_lst=( ${bin_size_lst[@]} $bin_size  )
min_lst=( ${min_lst[@]} ${min%.*} )
max_lst=( ${max_lst[@]} ${max%.*} )


echo "min ${ana_types[i]} --> ${min_lst[i]}"
echo "max ${ana_types[i]} --> ${max_lst[i]}"
echo "bin_size ${ana_types[i]} --> $bin_size "

#/usr/bin/python ${dir_py}/PyReweighting-1D.py -input ${fnames[i]}_4gamdFE.dat -cutoff 10 -Xdim ${min_lst[i]}  ${max_lst[i]} -disc $(( ( max_lst[i] - min_lst[i] ) / num_bin )) -Emax 20 -job amdweight_CE -weight weights.dat | tee -a ${fnames[i]}_reweight_variable.log
# following line is commented to remove limtis. I think the bash cannot parse floating points
#python ${dir_py}/PyReweighting-1D.py -input ${outfile[i]}.dat -cutoff 10 -Xdim ${min_lst[i]}  ${max_lst[i]} -disc ${binsiz[i]} -Emax 20 -job amdweight_CE -weight weights_all.dat | tee -a ${fnames[i]}_reweight_variable.log
python ${dir_py}/PyReweighting-1D.py -input ${outfile[i]}.dat -cutoff 50  -disc $bin_size -Emax 20 -job amdweight_CE -weight weights_all.dat -T $temp | tee -a ${fnames[i]}_reweight_variable.log

#/usr/bin/python ${dir_py}/PyReweighting-1D.py -input ${fnames[i]}_4gamdFE.dat -cutoff 10 -Xdim ${min_lst[i]}  ${max_lst[i]} -disc echo "${max_lst[i]} - ${min_lst[i]} / $num_bin | bc" -Emax 20 -job amdweight_CE -weight weights.dat | tee -a ${fnames[i]}_reweight_variable.log


mv -v pmf-c1-${outfile[i]}.dat.xvg pmf-c1-${outfile[i]}.xvg  
mv -v pmf-c2-${outfile[i]}.dat.xvg pmf-c2-${outfile[i]}.xvg  
mv -v pmf-c3-${outfile[i]}.dat.xvg pmf-c3-${outfile[i]}.xvg  

done

if [ ${#ana_types[@]} -gt 1 ];
then
paste -d " " ${fnames[0]}_4gamdFE_all.dat ${fnames[1]}_4gamdFE_all.dat > 2d_${fnames[0]}_${fnames[1]}_4gamdFE_all.dat

#/usr/bin/python ${dir_py}/PyReweighting-2D.py -cutoff 10 -input 2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat -Xdim ${min_lst[0]}  ${max_lst[0]} -discX $(( ( max_lst[0] - min_lst[0] ) / num_bin )) -Ydim ${min_lst[1]}  ${max_lst[1]} -discY $(( ( max_lst[1] - min_lst[1] ) / num_bin )) -Emax 20 -job amdweight_CE -weight weights.dat | tee -a 2d_${fnames[0]}_${fnames[1]}_reweight_variable.log
# following line is commented to remove limtis. I think the bash cannot parse floating points
python ${dir_py}/PyReweighting-2D.py -cutoff 10 -input 2d_${fnames[0]}_${fnames[1]}_4gamdFE_all.dat -Xdim ${min_lst[0]}  ${max_lst[0]} -discX ${bin_size_lst[0]}  -Ydim ${min_lst[1]}  ${max_lst[1]} -discY   ${bin_size_lst[1]} -Emax 20 -job amdweight_CE -weight weights_all.dat -T $temp | tee -a 2d_${fnames[0]}_${fnames[1]}_reweight_variable.log
#python ${dir_py}/PyReweighting-2D.py -cutoff 10 -input 2d_${fnames[0]}_${fnames[1]}_4gamdFE_all.dat  -discX  ${binsize_lst[0]} -discY ${binsize_lst[1]} -Emax 20 -job amdweight_CE -weight weights_all.dat | tee -a 2d_${fnames[0]}_${fnames[1]}_reweight_variable.log

mv -v pmf-c1-2d_${fnames[0]}_${fnames[1]}_4gamdFE_all.dat.xvg pmf-c1-2d_${fnames[0]}_${fnames[1]}_4gamdFE.xvg  
mv -v pmf-c2-2d_${fnames[0]}_${fnames[1]}_4gamdFE_all.dat.xvg pmf-c2-2d_${fnames[0]}_${fnames[1]}_4gamdFE.xvg  
mv -v pmf-c3-2d_${fnames[0]}_${fnames[1]}_4gamdFE_all.dat.xvg pmf-c3-2d_${fnames[0]}_${fnames[1]}_4gamdFE.xvg  

fi

echo "Done free energy calculations at $file "
cd $current_folder
done

