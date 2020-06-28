import numpy as np
import os
import sys
import matplotlib.pyplot as plt
import gc

def read_pdb (file1):
    residue, resid = 0, 1
    residue_index, resname_index, resid_index, segname_index = [], [], [], [] 
    with open('%s'%(file1), 'r') as f:
        data = f.readlines()
        for line in data:
            if line[0:4] == 'ATOM':
                if resid != int(line[22:27]):
                    residue = residue + 1
                    resid = int(line[22:27])
                    residue_index.append(residue)
                    resname_index.append(str(line[17:22]))
                    resid_index.append(int(line[22:27]))
                    segname_index.append(str(line[72:77]))
    return residue_index, resname_index, resid_index, segname_index

def read_contact_file (file1,time_stp,frames,column):
    print("\nreading --> {}".format(file1))
    with open('%s'%(file1), 'r') as f:
        data = f.readlines()
        print("simulation length of {}".format(len(data) * time_stp))
        data = list(map(lambda x: list(map(int, x.split('|')[column].split())), data))
        data = data[-frames:]
    print("finish reading")
    gc.collect()
    return data

