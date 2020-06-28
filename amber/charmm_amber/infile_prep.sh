#! /bin /bash
echo "Input file preperation"
enum=$1
cat << EOF > 1.in
EMIN
&cntrl
  imin   = 1,
  maxcyc = 10000,
  ncyc   = 5000,
  ntb    = 1,
  ntr    = 1,
  cut    = 10.0,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  fswitch = 8.0
 /
Hold the protein fixed
500.0
RES 1 $enum
END
END
EOF
cat << EOF > 2.in
initial minimization whole system
&cntrl
  imin   = 1,
  maxcyc = 20000,
  ncyc   = 10000,
  ntb    = 1,
  ntr    = 1,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  cut    = 10.0,
  fswitch = 10.0,
 /
Hold the protein fixed
500.0
RES 1 $enum
END
END

EOF
cat << EOF > 3.in
100 ps MD with res on protein
&cntrl
  imin   = 0,
  irest  = 0,
  ntx    = 1,
  ntb    = 1,
  cut    = 10.0,
  fswitch = 10.0,
  ntr    = 1,
  ntc    = 2,
  ntf    = 2,
  tempi  = 0.0,
  temp0  = 50.0,
  ntt    = 3,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  gamma_ln = 1.0,
  nstlim = 10000, dt = 0.002
  ntpr = 5000, ntwx = 5000 , ntwr = 5000 , ntxo=2 , ioutfm=1
/
Keep protein fixed with weak restraints
10.0
RES 1 $enum
END
END 
EOF
cat << EOF > 4.in
100 ps MD with res on protein
&cntrl
  imin   = 0,
  irest  = 1,
  ntx    = 5,
  ntb    = 1,
  cut    = 10.0,
  fswitch = 10.0,
  ntr    = 1,
  ntc    = 2,
  ntf    = 2,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  tempi  = 50.0,
  temp0  = 100.0,
  ntt    = 3,
  gamma_ln = 1.0,
  nstlim = 10000, dt = 0.002
  ntpr = 500, ntwx = 500 , ntwr = 500 , ntxo=2 , ioutfm=1
/
Keep protein fixed with weak restraints
10.0
RES 1 $enum
END
END 
EOF
cat << EOF > 5.in
100 ps MD with res on protein
&cntrl
  imin   = 0,
  irest  = 1,
  ntx    = 5,
  ntb    = 1,
  cut    = 10.0,
  fswitch = 10.0,
  ntr    = 1,
  ntc    = 2,
  ntf    = 2,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  tempi  = 100.0,
  temp0  = 150.0,
  ntt    = 3,
  gamma_ln = 1.0,
  nstlim = 10000, dt = 0.002
  ntpr = 500, ntwx = 500 , ntwr = 500 , ntxo=2 , ioutfm=1
/
Keep protein fixed with weak restraints
10.0
RES 1 $enum
END
END 
EOF

cat << EOF > 6.in
100 ps MD with res on protein
&cntrl
  imin   = 0,
  irest  = 1,
  ntx    = 5,
  ntb    = 1,
  cut    = 10.0,
  fswitch = 10.0,
  ntr    = 1,
  ntc    = 2,
  ntf    = 2,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  tempi  = 150.0,
  temp0  = 200.0,
  ntt    = 3,
  gamma_ln = 1.0,
  nstlim = 10000, dt = 0.002
  ntpr = 500, ntwx = 500 , ntwr = 500 , ntxo=2 , ioutfm=1
/
Keep protein fixed with weak restraints
10.0
RES 1 $enum
END
END 
EOF

cat << EOF > 7.in
100 ps MD with res on protein
&cntrl
  imin   = 0,
  irest  = 1,
  ntx    = 5,
  ntb    = 1,
  cut    = 10.0,
  fswitch = 10.0,
  ntr    = 1,
  ntc    = 2,
  ntf    = 2,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  tempi  = 200.0,
  temp0  = 250.0,
  ntt    = 3,
  gamma_ln = 1.0,
  nstlim = 10000, dt = 0.002
  ntpr = 500, ntwx = 500 , ntwr = 500 , ntxo=2 , ioutfm=1
/
Keep protein fixed with weak restraints
10.0
RES 1 $enum
END
END 
EOF

cat << EOF > 8.in
100 ps MD with res on protein
&cntrl
  imin   = 0,
  irest  = 1,
  ntx    = 5,
  ntb    = 1,
  cut    = 10.0,
  fswitch = 10.0,
  ntr    = 1,
  ntc    = 2,
  ntf    = 2,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  tempi  = 250.0,
  temp0  = 300.0,
  ntt    = 3,
  gamma_ln = 1.0,
  nstlim = 10000, dt = 0.002
  ntpr = 500, ntwx = 500 , ntwr = 500 , ntxo=2 , ioutfm=1
/
Keep protein fixed with weak restraints
10.0
RES 1 $enum
END
END 
EOF

cat << EOF > 9.in
500ps MD for equillibration
&cntrl
  imin   = 0,
  irest  = 1,
  ntx    = 5,
  ntb    = 1,
  cut    = 10.0,
  fswitch = 10.0,
  ntr    = 1,
  ntc    = 2,
  ntf    = 2,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  tempi  = 300.0,
  temp0  = 300.0,
  ntt    = 3,
  gamma_ln = 1.0,
  nstlim = 250000, dt = 0.002
  ntpr = 500, ntwx = 500 , ntwr = 500 , ntxo=2 , ioutfm=1
/
Keep protein fixed with weak restraints
10.0
RES 1 $enum
END
END 
EOF
cat << EOF > 10.in
40ns MD
&cntrl
  imin = 0, irest = 1, ntx = 7,
  ntb = 2, pres0 = 1.0, ntp = 1,
  taup = 2.0,
  cut    = 10.0,
  fswitch = 8.0,
  ntr = 0,
  ntc = 2, ntf = 2,
  watnam='TIP3',OWTNM='OH2', 
  hwtnm1='H1',hwtnm2='H2',   
  tempi = 300.0, temp0 = 300.0,
  ntt = 3, gamma_ln = 1.0,
  nstlim = 20000000, dt = 0.002,
  ntpr = 2500, ntwx = 2500, ntwr = 2500, ntxo=2, ioutfm=1
/
EOF
