import math
import sys
import os
import numpy as np
#pdb="rimer_1.pdb"
pdb = os.environ["t1"]
resid = os.environ["resid"]
resid=int(resid)
##################
llist = os.environ["llist"]
of=open("mutated_protien.pdb",'w')
infile_1=open(pdb)
llist=llist.split(',')
for llist2 in llist:
    llist2 = llist2.split('-')
    llist2 = [int(i) for i in llist2]
##################
    n=0
    a="ALA"
#####1###############
    for line in infile_1:
        d1=line.split()
        if (d1[0]=='ATOM'):
            d2=d1
            temp=int(d2[4])
            #temp=[float(i) for i in d1[4]
            while temp >= llist2[0] and temp <= llist2[1]:
                if ( temp  == resid):
                    while d1[2] in ["N", "H", "CA", "HA", "C", "O", "CB"]:
                        z=line.replace("%s"%d1[3], "%s"%a)
                        of.write('%s'%z)
                        break
                else:
                    of.write('%s'%line)
                break
        elif (d1[0]=='TER'):
	    of.write('%s'%line)
