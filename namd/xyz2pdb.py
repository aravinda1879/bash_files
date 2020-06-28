import os
import math
import sys
if_1=input('Please enter the xyz file name (python3)\n')
of_1=input('please enter the pdb output name you want\n')
a=1
b=0
c=1
l1=['C1','H1B','H1A','O1','C2','H2A','H2B']
of1=open(of_1,'w')
with open(if_1,'r') as f1:
    for line in f1:
        l2=line.split()
#        l3=l2[x] for x in [1,2,3] 
        if l2[0] in ["C", "H", "O"]:
            l3=[float(l2[x]) for x in [1,2,3]] 
            print(l3)
            of1.write('{:<6}{:>5} {:>4} {:<5}{:>4}    {:>8.3f}{:>8.3f}{:>8.3f}{:>6}{:>6}{:>8}\n'.format('ATOM', a, l1[b],'PEGMA', c, l3[0], l3[1], l3[2], '1.00', '0.00', 'A'))
            a = a + 1
            b = b + 1
            if b == 7:
                b = 0
                c = c + 1
of1.close()







