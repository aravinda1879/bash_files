#!/usr/bin/env python
# coding: utf-8

# In[1]:

import re
from Bio import pairwise2
from Bio import SeqIO
from Bio.Align import substitution_matrices
import sqlite3 as lite
import pandas as pd
import sys
import os
import subprocess
import matplotlib.pyplot as plt
from Bio.Align.Applications import TCoffeeCommandline
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio import SeqIO
from Bio import AlignIO
from collections import Counter
import numpy as np
from Bio.Data import IUPACData 
from Bio.SeqUtils.ProtParam import ProteinAnalysis
import copy
import subprocess

from modeller import *
from modeller.optimizers import MolecularDynamics, ConjugateGradients
from modeller.automodel import autosched
aa1to3 = {'C':'CYS', 'D':'ASP', 'S':'SER', 'Q':'GLN', 'K':'LYS',
          'I':'ILE', 'P':'PRO', 'T':'THR', 'F':'PHE', 'N':'ASN', 
          'G':'GLY', 'H':'HIS', 'L':'LEU', 'R':'ARG', 'W':'TRP', 
          'A':'ALA', 'V':'VAL', 'E':'GLU', 'Y':'TYR', 'M':'MET'}
#offset is important when fasta sequence in gemme is not the exact in the PDB
offset = 0 
numres_ha=494
#df = pd.read_csv('n1000_multi_fitnessE.csv',index_col=0)
df = pd.read_csv('1eo8_stem_fitnessE.csv',index_col=0)
modelname = '1eo8'
fol_prefix= '1eo8_stem_mod'
#494 resiues per monomer 
main_dir="/home/aravinda1879/research/polymer_vaccine/victor/struture_prep/1eo8mut_4_md/pdb4amber"
gemme_mut_lst = df.index
mutid_lst = []
for mut in gemme_mut_lst:
    elements = mut.split(',')
    temp,temp0 = [],[]
    temp2= []
    temp3= []
    for element in elements:
        for i in range(3):
            temp.append(f'{int(element[1:-1])-offset+(i*numres_ha)}-{aa1to3[str(element[-1])]}')
#    print(temp)
    mutid_lst.append(temp)
#    break
#sys.exit()
for i,mutSeq in enumerate(mutid_lst):
    fol=f'{fol_prefix}{i}'
    chk_fol = os.path.isdir(fol)
    if not chk_fol:
        os.makedirs(fol)
        print("created folder : ", fol)
    else:
        print(fol, "folder already exists.")
    os.chdir(fol)
    mut_string = ",".join(mutSeq)
    # shell=True subprocess.run(["pdb4amber -i ../1eo8.pdb --reduce --no-conect -o test.pdb"])
    subprocess.run(f'pdb4amber -i ../1eo8.pdb --reduce --no-conect -m {mut_string} -o {fol_prefix}{i}.pdb',shell=True )
    #subprocess.run(f'bash {main_dir}/renumber_rcsbID.sh {fol_prefix}{i}', shell=True)
    cnt    = 0
    newpdb_line=[]
    with open(f"{fol_prefix}{i}.pdb") as f1, open(f"{fol_prefix}{i}_renum.txt") as f2:
        pdb_file1 = f1.readlines()
        num_file2 = f2.readlines()
        for num_line in num_file2:
            newresid, oldresid = int(num_line.split()[3]), int(num_line.split()[1])
            #print(pdb_file1[cnt][0:3],newresid, pdb_file1[cnt][22:26])
            while (newresid == int(pdb_file1[cnt][22:26])):
                oldpdb_line = pdb_file1[cnt]
                newpdb_line.append(f'{oldpdb_line[0:22]}{oldresid:>4}{oldpdb_line[26:]}')
                cnt += 1
                if (pdb_file1[cnt][0:3] == 'END'):
                    #print("End of file reached")
                    break

    with open(f"{fol_prefix}{i}_renum.pdb", 'w') as newpdb_f:
        for newline in newpdb_line:
            newpdb_f.write(newline)

    
    os.chdir('../')

