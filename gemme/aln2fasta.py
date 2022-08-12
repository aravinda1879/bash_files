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
#from Bio.Alphabet import IUPAC
from Bio.Data import IUPACData 
from Bio.SeqUtils.ProtParam import ProteinAnalysis
print("Please type <gemme> as the first variabel for gemme type fasta, else <matlab>")
app_type = sys.argv[1]
infile = sys.argv[2]
of   = sys.argv[3]
IUPACData.protein_letters='ACDEFGHIKLMNPQRSTVWY-B'
aln_data  = []
#stem_H1_long_all_fft2.aln
hatype  = "H1" 
fasta_out=infile.replace('aln','fasta')
print("Reading the aln file")
aln_data = AlignIO.read(infile, "clustal")
print("Writing the pure conversion to fasta format")
SeqIO.write(aln_data, f'aln_0.0g_{fasta_out}', "fasta")
#for i in len(aln_data):
gap_pos = []
print(f"working on {len(aln_data[:,0])} sequences with # of  {len(aln_data[0,:])} in each")
for i in range(len(aln_data[0].seq)):
    if (app_type == "gemme"):
	#for gemma
        analysed_seq = ProteinAnalysis(aln_data[0,i])
    else:
	#for MPI_BML
        analysed_seq = ProteinAnalysis(aln_data[:,i])
    temp_d = analysed_seq.get_amino_acids_percent()
    if (temp_d['-']+temp_d['B'] > 0.9):
        gap_pos.append(i)
df0 = pd.DataFrame(data=aln_data)
df1 = df0.drop(columns=gap_pos)
temp = df1.to_string(header=False,
                  index=False,
                  index_names=False).split('\n')
joined_seq = [''.join(ele.split()) for ele in temp]

gr_aln_dat = []
for ind, row in enumerate(joined_seq):
    record = SeqRecord(Seq(row), id=aln_data[ind].id, name=aln_data[ind].name, description=aln_data[ind].description, dbxrefs=aln_data[ind].dbxrefs)
    gr_aln_dat.append(record)
SeqIO.write(gr_aln_dat, of, "fasta")
