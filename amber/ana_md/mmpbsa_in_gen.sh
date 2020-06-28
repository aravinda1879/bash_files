#! /bin/bash
echo "making the mmpbsa input file"
echo "how many 10ns rounds"
read nround
echo "how many frames intervals?"
read nsplit
echo "Do you want per residue energy decomposition (y/n)  "
read rpl_edecom
if [ $rpl_edecom == "y"  ]; then
echo "enter the interested decomposing region"
read ldecom
fi
COUNTER=1
while [ $COUNTER -lt $((nround + 1 ))  ]; do
mkdir run_$COUNTER
cd run_$COUNTER
if [ $COUNTER == "1"  ]; then
cat << EOF > mmpbsa_${COUNTER}.in
Input file for running PB and GB
&general
startframe= $(( 200 * ( COUNTER ) )) ,endframe= $(( 1999 * COUNTER )) , verbose=1,
   interval= $nsplit,
ligand_mask=':${llist}',
receptor_mask=':${rlist}'
#   entropy=1,
/
&gb
  igb=2, saltcon=0.100
/
&pb
  istrng=0.100, inp=2, radiopt=1
/
EOF
else
cat << EOF > mmpbsa_${COUNTER}.in
Input file for running PB and GB
&general
   startframe= $(( 2000 * ( COUNTER -1 ) )) ,endframe= $(( ( 2000 *  COUNTER ) - 1  )) , verbose=1,
   interval= $nsplit,
ligand_mask=':${llist}',
receptor_mask=':${rlist}'
#   entropy=1,
/
&gb
  igb=2, saltcon=0.100
/
&pb
  istrng=0.100, inp=2, radiopt=1
/
EOF
fi
if [ $rpl_mut == "y"  ]; then
cat << EOF >> mmpbsa_${COUNTER}.in
&alanine_scanning
/
EOF
fi
if [ $rpl_edecom == "y"  ]; then
cat << EOF >> mmpbsa_${COUNTER}.in
&decomp
idecomp=1, print_res="${ldecom}"
  dec_verbose=1,
/
EOF
fi
cd ..
 let COUNTER=COUNTER+1
done
