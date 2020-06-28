#!/bin/bash
wd_ana=e2e
current_folder=`pwd`
add="protein and "
file_list=( "$@" )

for file in ${file_list[@]} ; do
cd $file
mkdir ana_md
cd ana_md
mkdir $wd_ana
cd $wd_ana
bash ~/bash/namd/ana_namd/without_water_ana.sh
sed -i '/min/d' analysis_without_h2o.tcl
sed -i '/eq/d' analysis_without_h2o.tcl
sed -i '/_md1/d' analysis_without_h2o.tcl
#if [ $file == "b_N_p454/noR_2fs" ] 
#then 
#        sed -i -e 's/step 2/step 1/g' analysis_without_h2o.tcl
#fi
#checking if 10psd trajectory
if [ "${file##*_}" == "10ps" ]
then
        sed -i -e 's/step 2/step 1/g' analysis_without_h2o.tcl
fi

#add ana lines to each script
rm *dat
cat << EOF >> analysis_without_h2o.tcl
proc cal_func { sel1 sel2 of lsn } {
foreach sn \$lsn {
foreach i \$sel1  j \$sel2  k \$of {
puts "\$i \$j \$k"
set sel_1 "\$i and segname \$sn"
set sel_2 "\$j and segname \$sn"
set l_com_s1 [ distance  top "\$sel_1" "\$sel_2" com_\${sn}_\$k.dat ] 
distribution \$l_com_s1 top dis_com_\${sn}_\$k.dat 100 1
}
}
}

#for free polymer pCBMA
set sel1 [ list "resid 1 and name C2" ] 
set sel2 [ list "resid 18 and name C2" ] 
set lsn [ list "B" ]
set of [ list "c2_c2"  ]
cal_func \$sel1 \$sel2 \$of \$lsn

#for free pOEGMA25
#set sel1 [ list "resid 1 and name C1" "resid 0 and name C12" ] 
#set sel2 [ list "resid 265 and name BR1" "resid 0 and name N1" ] 
#set lsn [ list "FREE" ] 
#cal_func \$sel1 \$sel2 \$of \$lsn

#for free pOEGMA18
#set sel1 [ list "residue 1 and name C1" "resid 1 and name C12" ] 
#set sel2 [ list "resid 1 and name BR1" "resid 1 and name N1" ] 
#set lsn [ list "B" "A0" ]
#cal_func \$sel1 \$sel2 \$of \$lsn

#for just lz + initiator
#set lsn [ list A1 A13 A33  A97 A116 ]
#set sel1 [ list "resid 1 and name N1" ]
#set sel2 [ list "resid 1 and name C12 " ]
#set of [ list "n1_c12" ]
#cal_func \$sel1 \$sel2 \$of \$lsn

#for just lz + initiator + polymer
#set lsn [ list A1 A13 A33  A97 A116 ]
#set sel1 [ list "resid 0 and name N1" "resid 1 and name C1" ]
#set sel2 [ list "resid 0 and name C12 " "resid 35 and name BR1"] #pCBMA
#set sel2 [ list "resid 0 and name C12" "resid 265 and name BR1" ] 
#set of [ list "n1_c12" "c1_br" ]
#cal_func \$sel1 \$sel2 \$of \$lsn

#for free polymer pDMAEMA
#set sel1 [ list "resid 1 and name C1" ]
#set sel2 [ list "resid 60 and name C3" ]
#set lsn [ list "FREE" ]
#set of [ list "c1_c3" ]
#cal_func \$sel1 \$sel2 \$of \$lsn

#for free polymer pNIPAM
#set sel1 [ list "resid 1 and name C1" ]
#set sel2 [ list "resid 150 and name C3" ]
#set lsn [ list "FREE" ]
#set of [ list "c1_c3" ]
#cal_func \$sel1 \$sel2 \$of \$lsn

EOF
vmd -dispdev text -eofexit < analysis_without_h2o.tcl  > analysis.log
echo "Done at $file "
cd $current_folder
done

