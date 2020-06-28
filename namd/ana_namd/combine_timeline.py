import numpy as np
import os
import sys
import matplotlib.pyplot as plt
lst_dir = sys.argv[3:]
time_stp = float(sys.argv[1])
cut_percentage = float(sys.argv[2])
print(time_stp)
file = "ana_md/contact/contact_noH_residece_time.dat"
lst_res, lst_min_time, lst_max_time, lst_mean, lst_std, lst_tot_time = [], [], [], [], [], []
nparticles = 583 #remember this is res id equvalent not residue
sum_aray = np.zeros((nparticles,15000))
for f_dir in lst_dir:
    print("\nworking on {}".format(f_dir))
    with open('%s/%s'%(f_dir, file), 'r') as f:
        data = f.readlines()
        lst_tot_time.append(len(data) * time_stp)
        print("simulation length of {}".format(len(data) * time_stp))
        data = list(map(lambda x: list(map(int, x.split('|')[-1].split())), data))
    ntimesteps = len(data)
    data = [i for i in map(lambda arg: [nparticles] if arg[1] == [-1] else arg[1], enumerate(data))]
    tmp = list(np.bincount(d, minlength=nparticles) for d in data[-15000:])
    def pad_to_length(a, length):
        z = np.zeros(length)
        z[:a.shape[0]] = a
        return z
    new = np.array([pad_to_length(a, nparticles+1) for a in tmp]).T
    sum_aray = np.add(sum_aray,new)
cmap = plt.get_cmap()
cmap.set_under(color='white')
cmap.set_over('red')
fig, ax = plt.subplots(1, 1, figsize=(5,3))
cs=ax.contourf(sum_aray, cmap='jet')
ax.tick_params(labelsize='large')
plt.xlabel("Time (ns)",fontsize=18)
plt.ylabel("Residue number",fontsize=18)
plt.colorbar(cs)
plt.savefig('timeline_s.png',bbox_inches='tight',dpi=300,format='png')
