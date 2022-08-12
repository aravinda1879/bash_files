source ../namd_variables.sh
cat << EOF > mkmass.vmd
#!/bin/vmd

mol load psf ${final_psf_f}
mol addfile ${final_pdb_f}

# add masses to ions and OH2 atoms of water only ; note that I will set the mass of the latter at 18

set all [atomselect top "all" ];
\$all set beta 0

set ions [atomselect top "ions" ];
\$ions set beta [\$ions get mass] ;

set owat [atomselect top "resname TIP3 and name OH2" ];
\$owat set beta 18.0154 ;


\$all writepdb ${final_pdb_f%.*}-mass.pdb
EOF
