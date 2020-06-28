import os
import math
import sys
import numpy as np
import subprocess
##################   External variables
pdb = os.environ["t1"]
mlist = os.environ["mlist"]
llist = os.environ["llist"]
##################
mlist1 = mlist.split(',')
for mlist2 in mlist1:
    mlist2 = mlist2.split('-')
    mlist2 = [int(i) for i in mlist2]
    st, fi = mlist2[0], mlist2[1]
    while st <= fi:
        cmd3 = str(st)
        print st
        os.chdir(cmd3)
        cmd4 = "~/bash/ana_md/hotspot/prmtop_leap.sh "
#        subprocess.call(cmd4, shell=True)
        cmd5 = "~/bash/ana_md/hotspot/mmpbsa_in_gen.sh "+str(st)
#        subprocess.call(cmd5, shell=True)
        cmd6 = "~/bash/ana_md/hotspot/mmpbsa_script_gen.sh "+str(st)
        subprocess.call(cmd6, shell=True)
        os.chdir('..')
#        with open("run_list.sh", "a") as myfile:
#            myfile.write("\n cd %d"%st)
#            myfile.write("\n qsub script_%d"%st)
#            myfile.write("\n cd ..")
        st=st+1


