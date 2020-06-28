import numpy as np
import os
import sys
import matplotlib.pyplot as plt
import gc
infile1 = str(sys.argv[1])
infile2 = str(sys.argv[2])
outfile1 = str(sys.argv[3])
prefix = str(sys.argv[4])
#infile2 = "contact_noH_prot_wat_shell.dat"
#infile1 = "ct_hid_w_5ps_wb.pdb"
#ofile1="test"
file1 = '%s'%(infile1)
file2 = '%s/%s'%(prefix,infile2)
ofile1 = '%s/%s'%(prefix,outfile1)

residue_index, linedata, new_data, residue, resid = [], [], [], 0, 1

#reading pdb and dumping list with residue number
with open('%s'%(file1), 'r') as f:
    data = f.readlines()
    # data = list(map(lambda x: list( x.split()), data))
    for line in data:
        if line[0:4] == 'ATOM':
            if resid != int(line[22:27]):
                residue = residue + 1
                resid = int(line[22:27])
            residue_index.append(residue)
gc.collect()
#replacing index with residue
with open('%s'%(file2), 'r') as f:
    data1 = f.readline()
    data1 = f.readline()
    data = f.readlines()
print("done reading")
f.close()  
data = list(map(lambda x: list(map(int, x.split('|')[-1].split())), data))
print("done splitting")
gc.collect()
for tmp in data: 
    if tmp[0]==-1 or tmp[0]=="":
        new_data.append(-1)
    else:
        time_stp = list(set(tmp))
        new_data.append([residue_index[t] for t in time_stp])
#gc.collect()
with open(ofile1, 'w+') as tmp:
    for i, t in enumerate(new_data):
        tmp.write('{}|{}'.format(i,str(t).replace(',', '').replace('[', '').replace(']', '') + '\n'))
tmp.close()
print("done writing at {}".format(ofile1))
