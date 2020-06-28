#! /bin/bash
#echo "enter the pdb to seperate"
#read infile
#echo "enter chain letters"
#read ch1, ch2
grep ATOM 3URF.pdb | awk '{
if ( $5 == "A" ) print $0} > "t1.pdb"


else is ($5 =="Z" ) print $0 > "t2.pdb";

