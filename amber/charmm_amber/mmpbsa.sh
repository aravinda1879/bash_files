#! /bin/bash
echo "making the mmpbsa input file"
cat << EOF > mmpbsa.in
Input file for running PB and GB
&general
   endframe=50, verbose=1,
#   entropy=1,
/
&gb
  igb=2, saltcon=0.100
/
&pb
  istrng=0.100,
/
EOF
