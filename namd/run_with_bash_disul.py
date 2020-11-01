import os
import math
import sys
##################   External variables
infile1 = sys.argv[1]
infile2 = sys.argv[2]
outfile=open('out.pdb','w')
with open (infile1,'r') as f:
    dlist1=f.read().split('\n')
f.close()
#print(dlist1)
for dlist2 in dlist1:
    if dlist2:
        dlist2=dlist2.split()
        cdlist2=dlist2
        dlist2=[int(i) for i in dlist2]
        cdlist2=dlist2
        dlist2=map(int, dlist2)
        print(dlist2)
#        with open('renum.txt','r') as f2:
#            for line in f2:
#                line2=line.split()
#                #print(cdlist2[0],line2[3])
#                if cdlist2[0]==line2[3]:
#                    a=line2[1]
#                    print(a,line2[1])
#                if cdlist2[1]==line2[3]:
#                    b=line2[1]
#        f2.close()
#commented since no longer using original pdb resid
        outfile.write('patch DISU U1:{} U1:{} \n'.format(dlist2[0],dlist2[1]))
    else:
        print('DONE!')


#    i=1
#    mylist[i]=index
#    print(mylist)
#    i=i+1
#    print (mylist)

#
