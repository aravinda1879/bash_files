#!/bin/bash
wd_ana=gamdFE
current_folder=`pwd
`
conda activate py2
<<COMMENT1
Use this script only to run free energy calculations on two types of files at ones. setting morethan two variables at the ana_types will cause problems at the 2D free energy calculation section. 

REMEMBER TO SET THE TEMPERATURE

Also set pythonpath to empty 
COMMENT1
#export PYTHONPATH=""
file_list=( "$@" )
dir_py="/home/${USER}/bash/namd/ana_namd/gamd_ana"
for file in ${file_list[@]} ; do
echo "#######################################################"
echo "running in $file"
echo "#######################################################"

cd $file
mkdir ana_gamd
cd ana_md
mkdir $wd_ana
cd $wd_ana
temp=310.5
max_lst=()
min_lst=()
bin_size_lst=()
num_bin=10
ana_types=( "rg" "e2e" )
fnames=( "rg_B_polymer" "com_B_c2_c2" )
file_log=($( ls ../../log_md/*_gmd* | sort --version-sort ))
min=0
max=0

#grep "ETITLE:"  ${file_log[2]} | tail -1 > log_sum.log 
rm *.dat
rm *.log
rm *.dat*
for i in ${file_log[@]} ; do
grep "ACCELERATED MD: STEP" ${i} | awk 'NR%1==0' | awk -v t="$temp" '{ if(NR>1) print $6/(0.001987*t)" " $4 " " $6 " "$8 }' >> weights.dat
done
for ((i=0;i<${#ana_types[@]};++i)); do
rm  ${fnames[i]}_4gamdFE.dat
grep "" ../${ana_types[i]}/${fnames[i]}.dat | awk '{print $2}' > ${fnames[i]}_4gamdFE.dat
min=`awk 'BEGIN{a=10000000}{if ($1<0+a) a=$1} END{print a}' ${fnames[i]}_4gamdFE.dat`
max=`awk 'BEGIN{a=   0}{if ($1>0+a) a=$1} END{print a}' ${fnames[i]}_4gamdFE.dat`
min_lst=( ${min_lst[@]} ${min%.*} )
max_lst=( ${max_lst[@]} ${max%.*} )
echo "min ${ana_types[i]} --> ${min_lst[i]}"
echo "max ${ana_types[i]} --> ${max_lst[i]}"
bin_size=`awk "BEGIN {print (${max_lst[i]} -  ${min_lst[i]})/$num_bin }"`
bin_size_lst=( ${bin_size_lst[@]} $bin_size  )
echo "bin_size ${ana_types[i]} --> $bin_size "

#/usr/bin/python ${dir_py}/PyReweighting-1D.py -input ${fnames[i]}_4gamdFE.dat -cutoff 10 -Xdim ${min_lst[i]}  ${max_lst[i]} -disc $(( ( max_lst[i] - min_lst[i] ) / num_bin )) -Emax 20 -job amdweight_CE -weight weights.dat | tee -a ${fnames[i]}_reweight_variable.log
# following line is commented to remove limtis. I think the bash cannot parse floating points
# python ${dir_py}/PyReweighting-1D.py -input ${fnames[i]}_4gamdFE.dat -cutoff 50 -Xdim ${min_lst[i]}  ${max_lst[i]} -disc $bin_size -Emax 20 -job amdweight_CE -weight weights.dat | tee -a ${fnames[i]}_reweight_variable.log
python ${dir_py}/PyReweighting-1D.py -input ${fnames[i]}_4gamdFE.dat -cutoff 10 -disc $bin_size -Emax 20 -job amdweight_CE -weight weights.dat | tee -a ${fnames[i]}_reweight_variable.log

#/usr/bin/python ${dir_py}/PyReweighting-1D.py -input ${fnames[i]}_4gamdFE.dat -cutoff 10 -Xdim ${min_lst[i]}  ${max_lst[i]} -disc echo "${max_lst[i]} - ${min_lst[i]} / $num_bin | bc" -Emax 20 -job amdweight_CE -weight weights.dat | tee -a ${fnames[i]}_reweight_variable.log


mv -v pmf-c1-${fnames[i]}_4gamdFE.dat.xvg pmf-c1-${fnames[i]}_4gamdFE.xvg  
mv -v pmf-c2-${fnames[i]}_4gamdFE.dat.xvg pmf-c2-${fnames[i]}_4gamdFE.xvg  
mv -v pmf-c3-${fnames[i]}_4gamdFE.dat.xvg pmf-c3-${fnames[i]}_4gamdFE.xvg  

done

if [ ${#ana_types[@]} -gt 1 ];
then
paste -d " " ${fnames[0]}_4gamdFE.dat ${fnames[1]}_4gamdFE.dat > 2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat

#/usr/bin/python ${dir_py}/PyReweighting-2D.py -cutoff 10 -input 2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat -Xdim ${min_lst[0]}  ${max_lst[0]} -discX $(( ( max_lst[0] - min_lst[0] ) / num_bin )) -Ydim ${min_lst[1]}  ${max_lst[1]} -discY $(( ( max_lst[1] - min_lst[1] ) / num_bin )) -Emax 20 -job amdweight_CE -weight weights.dat | tee -a 2d_${fnames[0]}_${fnames[1]}_reweight_variable.log
# following line is commented to remove limtis. I think the bash cannot parse floating points
#python ${dir_py}/PyReweighting-2D.py -cutoff 10 -input 2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat -Xdim ${min_lst[0]}  ${max_lst[0]} -discX ${bin_size_lst[0]} -Ydim ${min_lst[1]}  ${max_lst[1]} -discY ${bin_size_lst[1]} -Emax 20 -job amdweight_CE -weight weights.dat | tee -a 2d_${fnames[0]}_${fnames[1]}_reweight_variable.log
python ${dir_py}/PyReweighting-2D.py -cutoff 10 -input 2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat  -discX ${binsize_lst[0]} -discY  ${binsize_lst[1]} -Emax 20 -job amdweight_CE -weight weights.dat | tee -a 2d_${fnames[0]}_${fnames[1]}_reweight_variable.log


mv -v pmf-c1-2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat.xvg pmf-c1-2d_${fnames[0]}_${fnames[1]}_4gamdFE.xvg  
mv -v pmf-c2-2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat.xvg pmf-c2-2d_${fnames[0]}_${fnames[1]}_4gamdFE.xvg  
mv -v pmf-c3-2d_${fnames[0]}_${fnames[1]}_4gamdFE.dat.xvg pmf-c3-2d_${fnames[0]}_${fnames[1]}_4gamdFE.xvg  

fi

echo "Done calculations at $file "
cd $current_folder
done
conda deactivate
