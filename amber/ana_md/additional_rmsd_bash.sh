#!/bin/bash
cat << EOF > additional_rmsd.trajin
parm parm_strip_h20.prmtop
trajin combined_striph20_mdcrd2binpos.binpos
rmsd first out rmsd_to_emin.dat @N,CA,C time 0.2
rmsd first out rmsd_opg_1.dat :313-476@N,CA,C time 0.2
rmsd first out rmsd_opg_2.dat :633-796@N,CA,C time 0.2
rmsd first out rmsd_crd2_1.dat :352-392@N,CA,C time 0.2
rmsd first out rmsd_crd3_1.dat :394-429@N,CA,C time 0.2
rmsd first out rmsd_crd2_2.dat :672-712@N,CA,C time 0.2
rmsd first out rmsd_crd3_2.dat :714-749@N,CA,C time 0.2
rmsd first out rmsd_both_opg.dat :313-476,633-796@N,CA,C time 0.2
atomicfluct out bfactor_all.dat :1-796 byres start 500
rmsd first out rmsd_rankl_1.dat :1-156@N,CA,C time 0.2
rmsd first out rmsd_rankl_2.dat :157-312@N,CA,C time 0.2
rmsd first out rmsd_rankl_3.dat :477-632@N,CA,C time 0.2
rmsd first out rmsd_rankl_cd_1.dat :64-73@N,CA,C time 0.2
rmsd first out rmsd_rankl_cd_2.dat :220-229@N,CA,C time 0.2
rmsd first out rmsd_rankl_cd_1.dat :540-549@N,CA,C time 0.2
rmsd first out rmsd_rankl_de_1.dat :85-89@N,CA,C time 0.2
rmsd first out rmsd_rankl_de_2.dat :241-245@N,CA,C time 0.2
rmsd first out rmsd_rankl_de_3.dat :561-565@N,CA,C time 0.2
rmsd first out rmsd_rankl_aa_1.dat :18-20@N,CA,C time 0.2
rmsd first out rmsd_rankl_aa_2.dat :174-176@N,CA,C time 0.2
rmsd first out rmsd_rankl_aa_3.dat :494-549@N,CA,C time 0.2
distance f96 :724 :585 out f96_1.dat
distance f96 :404 :265 out f96_2.dat
hbond out ../hbond/hbond_all.dat avgout hbond_all_avg.dat
trajout combined_all_mdcrd2binpos.binpos binpos
EOF
