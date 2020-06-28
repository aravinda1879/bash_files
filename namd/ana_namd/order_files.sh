#! /bin/bash
echo "seperating files into different folders and then move water after removing water"
mkdir log_md
mv *log log_md/.
mkdir restart_md
mv *restart.* restart_md/.  
mv *xst restart_md/.
mv *xsc restart_md/.
mv *vel restart_md/.
mv *coor restart_md/.
mkdir conf_md
mv *conf conf_md/.
echo "to remove water please run the following commoand"
echo "bash ~/bash/namd/ana_namd/remove_water_psf.sh" 
