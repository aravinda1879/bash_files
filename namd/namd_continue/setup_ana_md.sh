#!/bin/bash
for i in `seq 5 10`;
do 
prefix=b10kRimd${i}
cd b10kRimd${i}_5ps
mkdir ana_md
cd ana_md
mkdir test_dir
cd test_dir
bash /home/aravinda1879/bash/namd/ana_namd/water_ana.sh
bash /home/aravinda1879/bash/namd/ana_namd/without_water_ana.sh
sed -i '/min/d' ./*
mv analysis_h2o.tcl ../.
mv analysis_without_h2o.tcl ../.
cd ..
rm -r test_dir
cd ../..
done
