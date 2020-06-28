import math
import sympy as sp
import numpy as np
f_1= raw_input('File one with extension')
f_2= raw_input('file two with extesion')
##################
#f_1 = "3URF.pdb"
#f_2 =  "o_r_ini.pdb"
#f_3 = "matched_resid"
infile_1=open(f_1)
infile_2=open(f_2)
of=open("matched_res",'w')
temp="as"
t1,t2="1","2"
dd=0
###################
for line1 in infile_1:
    d1 =line1.split()
    if (d1[0] == 'ATOM'):
        if(d1[5]!=t1):
            for line2 in infile_2:
                d2=line2.split()
                if(d2[0]=='ATOM' and d1[3] == d2[3] and temp != d1[5] ):
                    of.write('%s\t%s-->%s\t%s\n' % (d1[3],d1[5],d2[3],d2[4]))
                    print (d1[3],d1[5],d2[3],d2[4])
                    temp=d1[5]
                    break
                elif(d2[0]=='ATOM' and d1[3] == "HIS" and temp != d1[5]):
                    if(d2[3] =="HIE" or d2[3] == "HID" or d2[3] == "HIP"):
                        of.write('%s\t%s-->%s\t%s\n' % (d1[3],d1[5],d2[3],d2[4]))
                        print (d1[3],d1[5],d2[3],d2[4])
                        temp=d1[5]
                        break
            t1=d1[5]
print("final")
print("DONE!!!!!!!!!!!!")
of.close()
