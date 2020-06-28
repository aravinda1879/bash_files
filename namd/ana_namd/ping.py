#!/usr/bin/python
import os, sys
import argparse
import numpy as np
# import pandas as pd 
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.cm as cm

parser = argparse.ArgumentParser(prog='extract_biocon_contact_info')
parser.add_argument('--pdb', nargs=1)
parser.add_argument('--ts', nargs=1)
parser.add_argument('--con', nargs='*')

args = parser.parse_args()

pdb_file = open(args.pdb[0], "r")
records  = pdb_file.readlines()
pdb_file.close()

atoms = []
atom2res = {}
for record in records:
    if len(record) >= 14 and record[0:4] == 'ATOM':
        atom = {'atomSerial': int(record[ 6:11].strip()), \
                'atomName': record[12:16].strip(), \
                'resName': record[17:20].strip(), \
                'chainID': record[21:22].strip(), \
                'resSeq': int(record[22:26].strip()),}
        atoms.append(atom)
        atom2res[atom['atomSerial']] = atom['resSeq']
    atoms.sort(key=lambda a: a['atomSerial'])

resSeq_pPEGMA_pHPMA = range(1, 170+1)
resSeq_OPG = range(137, 304+1)

con_mat = np.zeros((len(resSeq_OPG), len(resSeq_pPEGMA_pHPMA)))
con_OPG_t = []
con_pPEGMA_pHPMA_t = []

ts = float(args.ts[0])
n = 0
for f in args.con:
    print "processing file:", f
    with open(f) as fp:
        for line in fp:
            n += 1
            # if n > 5: break
            if line.find("{") != -1:
                con_mat_t = np.zeros((len(resSeq_OPG), len(resSeq_pPEGMA_pHPMA)))
                contacts_ORG = line.split('{')[1].split('}')[0].split(' ')
                contacts_pPEGMA_pHPMA = line.split('{')[2].split('}')[0].split(' ')
                # print contacts_ORG, contacts_pPEGMA_pHPMA
                if contacts_ORG != ['']:
                    contacts_ORG = map(int, contacts_ORG)
                else:
                    contacts_ORG = []
                if contacts_pPEGMA_pHPMA != ['']:
                    contacts_pPEGMA_pHPMA = map(int, contacts_pPEGMA_pHPMA)
                else:
                    contacts_pPEGMA_pHPMA = []
                if len(contacts_ORG) != len(contacts_pPEGMA_pHPMA):
                    print "Error in the contact pairs"
                ixiy_list = []
                con_OPG_array = np.zeros(len(resSeq_OPG))
                con_pPEGMA_pHPMA_array = np.zeros(len(resSeq_pPEGMA_pHPMA))
                for i in range(len(contacts_ORG)):
                    # print contacts_ORG[i], contacts_pPEGMA_pHPMA[i]
                    ix = atom2res[contacts_ORG[i]+1]-137
                    iy = atom2res[contacts_pPEGMA_pHPMA[i]+1]-1
                    con_mat_t[ix][iy] += 1
                    ixiy_list.append((ix, iy))
                for ix,iy in set(ixiy_list): 
                    # if con_mat_t[ix][iy] > 0 :
                    # print ix, iy, con_mat_t[ix][iy]
                    con_mat[ix][iy] += 1
                    con_OPG_array[ix] += 1
                    con_pPEGMA_pHPMA_array[iy] += 1
                con_OPG_t.append(con_OPG_array)
                con_pPEGMA_pHPMA_t.append(con_pPEGMA_pHPMA_array) 

with file('OPG_vs_pPEGMA_pHPMA.txt', 'w') as outfile:
    outfile.write('# Array shape: {0}\n'.format(con_mat.shape))
    # for data_slice in con_mat:
    np.savetxt(outfile, con_mat, fmt='%-7.2f')

g_size = 10 
gx_size = g_size
gy_size = g_size * 5

vmax = np.max(con_mat.flatten()) / 8.0

fig1 = plt.figure(1, figsize=(g_size,g_size))
plt.tick_params(labelsize=20)
plt.imshow(con_mat, aspect='auto', extent=[1, 171, 137, 305],  interpolation='none', origin='lower', cmap=cm.binary, vmax=vmax)
plt.colorbar()
plt.draw()
map1_filename = "OPG_vs_pPEGMA_pHPMA.png"
fig1.savefig(map1_filename, dpi=1200)
plt.gcf().clear()

OPG_vs_t = np.array(con_OPG_t)
pPEGMA_pHPMA_vs_t = np.array(con_pPEGMA_pHPMA_t)
nt = float(OPG_vs_t.shape[0]) * 0.002 

with file('OPGpp_vs_t.txt', 'w') as outfile:
    outfile.write('# Array shape: {0}\n'.format(OPG_vs_t.shape))
    # for data_slice in con_mat:
    np.savetxt(outfile, OPG_vs_t, fmt='%-7.2f')

with file('pPEGMA_pHPMA_vs_t.txt', 'w') as outfile:
    outfile.write('# Array shape: {0}\n'.format(pPEGMA_pHPMA_vs_t.shape))
    # for data_slice in con_mat:
    np.savetxt(outfile, pPEGMA_pHPMA_vs_t, fmt='%-7.2f')

nvmax = 6.0

fig2 = plt.figure(1, figsize=(g_size,gy_size))
plt.tick_params(labelsize=20)
plt.imshow(OPG_vs_t.T, aspect='auto', extent=[0, nt, 137, 305], interpolation='none', origin='lower', cmap=cm.binary, vmax=nvmax)
# plt.colorbar()
# plt.show()
plt.draw()
map2_filename = "OPGpp_vs_t.png"
fig2.savefig(map2_filename, dpi=1200)
plt.gcf().clear()

fig2a = plt.figure(1, figsize=(g_size,gy_size))
plt.tick_params(labelsize=20)
plt.contourf(OPG_vs_t.T, extent=[0, nt, 137, 305], origin='lower', cmap=cm.binary)
# plt.colorbar()
plt.draw()
map2a_filename = "OPGpp_vs_t_contour.png"
fig2a.savefig(map2a_filename)
plt.gcf().clear()

nvmax = 3.0

fig3 = plt.figure(1, figsize=(g_size,gy_size))
plt.tick_params(labelsize=20)
plt.imshow(pPEGMA_pHPMA_vs_t.T, aspect='auto', extent=[0, nt, 1, 171], interpolation='none', origin='lower', cmap=cm.binary, vmax=nvmax)
# plt.colorbar()
# plt.show()
plt.draw()
map3_filename = "pPEGMA_pHPMA_vs_t.png"
fig3.savefig(map3_filename, dpi=1200)
plt.gcf().clear()

fig3a = plt.figure(1, figsize=(g_size,gy_size))
plt.tick_params(labelsize=20)
plt.contourf(pPEGMA_pHPMA_vs_t.T, extent=[0, nt, 1, 171], origin='lower', cmap=cm.binary)
# plt.colorbar()
plt.draw()
map3a_filename = "pPEGMA_pHPMA_vs_t_contour.png"
fig3a.savefig(map3a_filename)
plt.gcf().clear()






        
