#!/bin/bash
wd_ana=rg
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
proc cal_func { sel1 of lsn } {
foreach sn \$lsn {
foreach i \$sel1  k \$of {
set sel_1 "\$i and segname \$sn"
#if {[llength \$lsn] == 1} {
#set sn "of"
#}
set l_rg [ Rg  top "\$sel_1"  rg_\${sn}_\$k.dat ] 
distribution \$l_rg top dis_rg_\${sn}_\$k.dat 100 1
}
}
}


####protein
#set sel1 [ list "protein" "protein backbone"  ]
#set of [ list "pro_all"  "pro_bb" ]
#set lsn [list "U1"]
#cal_func \$sel1 \$of \$lsn

####each polymer in conjugate
#set sel1 [list "not resname PIT" ]
#set of [ list "pol_all" ]
#set lsn [ list A1 A13 A33  A97 A116 ]
#cal_func \$sel1 \$of \$lsn

####Just for free polymers
set sel1 [list "all not water and not ion" ]
set of [ list "polymer" ]
set lsn [ list B ]
cal_func \$sel1 \$of \$lsn

#whole conjugate
#set sel1 [list "not ion and not water" ]
#set of [ list "all" ]
#set lsn [ list "A1 A13 A33  A97 A116" ]
#cal_func \$sel1 \$of \$lsn




EOF
vmd -dispdev text -eofexit < analysis_without_h2o.tcl  > analysis.log
echo "Done Rg calculations at $file "
cd $current_folder
done
