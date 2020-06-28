import math
import sympy as sp
import numpy as np
f_1= raw_input('File one (before amber) with extension')
f_2= raw_input('file two with extesion')
##################
#f_1 = "3URF.pdb"
#f_2 =  "o_r_ini.pdb"
#f_3 = "matched_resid"
infile_1=open(f_1)
infile_2=open(f_2)
of=open("matched_res",'w')
temp="as"
dd=0
###################
for line1 in infile_1:
    d1 =line1.split()
    if (d1[0] == 'ATOM'):
        print(d1[3])
#        if (d1[3] == 'HIS'):
#            aa=2
        aa=1
        while aa==1:
            a=1
            for line2 in infile_2:
                d2=line2.split()
                print d2
                if(d2[0]=='ATOM'):
                    if (d1[3] == d2[3]):
                        dd=dd+1
                        print d1[3],d2[3]
                        print temp,dd
                        if (temp != d1[5]):
                            print "after temp"
                            temp=d1[5]
                            of.write('%s\t%s-->%s\n' % (d2[3],d1[5],d2[4]))
                            a=2
                    else:
                        if (d1[3]=='HIS'):
                            if(d2[3]=='HIE'):
                                if (temp != d1[5]):
                                    print "came here"
                                    temp=d1[5]
                                    aa=2
                                    of.write('%s\t%s-->%s\n' % (d2[3],d1[5],d2[4]))
                                    a=2
                        a=2
                if (a==2):
                    print "this is break"
                    break
            aa=2
print("final")
of.close()


#                    d2=line2.split()
#                    if(d2[0]=='ATOM'):
#                    outfile_1.write()
