#!/bin/bash
ls ../
echo "enter the ../ part"
read outdr
process_mdout.perl $outdr
#density file eddition
grep '' summary.DENSITY |awk '{
 if ($1 > 50 )
         print $1, $2
}' > summary_no50ps.DENSITY
fn=summary.ETOT
fo=md_en.dat
echo "Assuming system was heated for 50 ps"
echo "removing temperature heating trajectories"
grep '' $fn |awk '{
 if ($1 > 50 )
	 print $1, $2
}' > $fo
 
echo "DONE stripping temperature!!"
cat $fo|awk '{
if ($2 < min)
	{min = $2;
	print $1"    "min
	}
}'
rm $fo
echo "enter the lowest energy time"
read le
grep $le ../*.out
ls ../*mdcrd
echo "enter *.mdcrd file name"
read tra
grep $le ../*.out | awk '{print $4}' > temp.dat
nstep=$(cat "temp.dat")
echo "NSTEP of lowest energy conformation is "$nstep
rm temp.dat
echo "Divide NSTEP by ntwx of your input and enter"
read frame
file=exatract_frame_${frame}.trajin
### MAKING THE RMSD directory
mkdir binpos
cd binpos
cat << EOF > $file
trajin ../../$tra $frame $frame 
trajout low_e.pdb pdb
EOF
cpptraj -p ../../*prmtop -i $file
cat << EOF > parm_strip.trajin
parm ../../*prmtop
parmstrip :WAT
parmwrite out parm_strip_h20.prmtop
EOF
cpptraj -i parm_strip.trajin 
mkdir ../hbond
cp parm_strip_h20.prmtop ../hbond/.
cat << EOF > mdcrd_strip_skip.trajin
parm parm_strip_h20.prmtop
trajin combined_strip_mdcrd2binpos.binpos
hbond hb1 out ../hbond/hb_uu.dat dist 3.5 avgout ../hbond/hb_uu_avg.dat solvout ../hbond/hb_uv_avg.dat bridgeout ../hbond/bridge_uu_avg.dat series uuseries ../hbond/time_uu_avg.dat
run 
runanalysis lifetime hb1[solutehb] out lifehb_uu.dat 
run
EOF
echo"***********************************************************************"
echo "starting calculation of RMSD of carbon back bone binpos file formation"
echo "**********************************************************************"
cat << EOF > measure_rmsd.trajin
trajin ../../*.mdcrd
reference low_e.pdb
rmsd reference out rmsd_to_low_e.dat @N,CA,C time 0.2
rmsd first out rmsd_to_emin.dat @N,CA,C time 0.2
trajout combined_all_mdcrd2binpos.binpos binpos
EOF
cat << EOF > strip_h20_binpos.trajin
trajin ../../*.mdcrd
strip :WAT
trajout combined_striph20_mdcrd2binpos.binpos binpos
run
EOF
echo "cpptraj -p ../../*prmtop -i measure_rmsd.trajin RUN THIS MANUALLY after editing mdcrd input :) "
echo " cpptraj -i mdcrd_strip_skip.trajin RUN THIS MANUALLY after getting the binpos file :) "
echo "cpptraj -p ../../*prmtop -i strip_h20_binpos.trajin MANNUALLY after all"
