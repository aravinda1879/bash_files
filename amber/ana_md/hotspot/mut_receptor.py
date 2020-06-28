import os
import math
import sys
import numpy as np
##################   External variables
pdb = os.environ["t1"]
mlist = os.environ["mlist"]
llist = os.environ["llist"]
fname="mutated_receptor.pdb"
##################
#t=raw_input('stop mut receptro')
mlist1=mlist.split(',')
for mlist2 in mlist1:
    mlist2 = mlist2.split('-')
    mlist2 = [int(i) for i in mlist2]
    st,fi=mlist2[0], mlist2[1]
    while st <= fi:
        cmd3 = str(st)
        os.chdir(cmd3)
        of=open(fname,'w')
        llist1=llist.split(',')
        for llist2 in llist1:
            llist2 = llist2.split('-')
            llist2 = [int(i) for i in llist2]
##################
            a="ALA"
            infile_1=open(pdb)
            for line in infile_1:
                d1=line.split()
                if (d1[0]=='ATOM'):
                    d2=d1
                    temp=int(d2[4])
                    while temp >= llist2[0] and temp <= llist2[1]:
                        if ( temp  == st):
                            while d1[2] in ["N", "H", "CA", "HA", "C", "O", "CB"]:
                                z=line.replace("%s"%d1[3], "%s"%a)
                                of.write('%s'%z)
                                break
                        else:
                            of.write('%s'%line)
                        break
                elif (d1[0]=='TER'):
	                of.write('%s'%line)
            infile_1.close()
        of.close()
        cmd4 = "pdb4amber -i "+str(fname)+" -o _mutated_receptor.pdb --dry > _receptor_pdb4amb"
        os.system(cmd4)
        os.chdir('..')
        st=st+1
