import numpy as np
import os
import sys
import matplotlib.pyplot as plt
import gc
from common_def import read_pdb, read_contact_file

time_stp = float(sys.argv[1])
frames = int(sys.argv[2])
infile1 = str(sys.argv[3])
infile2 = str(sys.argv[4])
outfile = str(sys.argv[5])
column  = int(sys.argv[6])
lst_dir = sys.argv[7:]


for ii,f_dir in enumerate(lst_dir):
    print("\nworking on {}".format(f_dir))
    pdb_file = '%s/%s'%(f_dir,infile1)
    residue_index, resname_index, resid_index, segname_index = read_pdb(pdb_file)
    data_file = "ana_md/contact/%s"%(infile2)
    data = read_contact_file(data_file,time_stp,frames,column)
    print("number of data frames = %s"%(len(data)))
    nparticles=max(residue_index) + 1
    tmp = list(np.bincount(d, minlength=nparticles) for d in data)


