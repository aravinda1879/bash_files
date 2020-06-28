import math
import os
pdb = os.environ["t1"]
##################
infile_1=open(pdb)
of=open("mutated_protien.pdb",'w')
n=0
a="ALA"
#####1###############
for line in infile_1:
    d1=line.split()
    if (d1[0]=='ATOM'):
        if (d1[4] == resid):
            while d1[2] in ["N", "H", "CA", "HA", "C", "O"]:
                z=line.replace("%s"%d1[3], "%s"%a)
                of.write('%s'%z)
                break
        else:
            of.write('%s'%line)

