import os
import math
import sys
import re
#if1=open('final_2_3.pdb','r')
#if2=open('final_1.pdb','r')
cmd1="ls"
os.system(cmd1)
print('Please only use this when PDB of psfgen wanted to updated with gausview\n')
i_f1=input('please enter the gausview pdb\n')
i_f2=input('please enter the psfgen pdb file\n')
o_f1=input('Please enter the final pdb name you want\n')
of1=open(o_f1,'w')
with open(i_f2,'r') as f1:
    for line in f1:
        l1=line.split()
        if l1[0] in ["REMARK", "TER", "END"]:
            of1.write(line)
        else:
            with open(i_f1,'r') as f2:
                for line2 in f2:
                    l2=line2.split()
                    if l2[0] in ["REMARK", "TER", "END", "CONECT"]:
                        continue
                    if l1[1]==l2[1]:
                       # z1=line.replace("%s"%l1[6],"%s"%l2[6])
                        if l1[3]=='PEGMA':
                            of1.write('{:<6}{:>5} {:>4} {:<5}{:>4}    {:>8}{:>8}{:>8}{:>6}{:>6}{:>8}\n'.format(l1[0], l1[1], l1[2], l1[3], l1[4], l2[6], l2[7], l2[8], l1[8], l1[9], l1[10]))
                            break
                        else:
                            of1.write('{:<6}{:>5} {:>4} {:<3} {:1}{:>4}    {:>8}{:>8}{:>8}{:>6}{:>6}{:>8}\n'.format(l1[0], l1[1], l1[2],\
                                                     l1[3], l1[4], l1[5], l2[6], l2[7], l2[8], l1[9], l1[10], l1[11]))
                            break


                       # z2=z1.replace("%s"%l1[7],"%s"%l2[7])
                       # z3=z2.replace("%s"%l1[8],"%s"%l2[8])
                       # of1.write(z3)
                f2.close()
of1.close()
