import numpy as np
import os
import sys
import matplotlib.pyplot as plt
lst_dir = sys.argv[5:]
time_stp = float(sys.argv[1])
cut_percentage = float(sys.argv[2])
infile = str(sys.argv[3])
outfile = str(sys.argv[4])
print(time_stp)
file = "ana_md/contact/%s"%(infile)
lst_res, lst_min_time, lst_max_time, lst_mean, lst_std, lst_tot_time = [], [], [], [], [], []
for f_dir in lst_dir:
    print("\nworking on {}".format(f_dir))
    with open('%s/%s'%(f_dir, file), 'r') as f:
        data = f.readlines()
        lst_tot_time.append(len(data) * time_stp)
        print("simulation length of {}".format(len(data) * time_stp))
        data = list(map(lambda x: list(map(int, x.split('|')[-1].split())), data))
    ntimesteps = len(data)
    nparticles = 583 #remember this is res id equvalent not residue 
    data = [i for i in map(lambda arg: [nparticles] if arg[1] == [-1] else arg[1], enumerate(data))]
    tmp = list(np.bincount(d, minlength=nparticles) for d in data)
    def pad_to_length(a, length):
        z = np.zeros(length)
        z[:a.shape[0]] = a
        return z
    new = np.array([pad_to_length(a, nparticles+1) for a in tmp]).T
    def residence_times(arr):
        """print(arr.shape)"""
        bounded = np.hstack(([0], arr, [0]))
        difs = np.diff(bounded)
        run_starts, = np.where(difs > 0)
        run_ends, = np.where(difs < 0)
        return (run_ends - run_starts) * time_stp
    res = [residence_times(a) for a in new]
    #lst_res.append(res)
    mean = np.nan_to_num([np.mean(r) for r in res])
    lst_mean.append(mean)
    std = np.nan_to_num([np.std(r) for r in res])
    lst_std.append(std)
    max_res = []
    min_res = []
    for i, r in enumerate(res):
        try:
            max_res.append(float(np.nan_to_num(np.max(r))))
        except:
            max_res.append(0)
        try:
            min_res.append(float(np.nan_to_num(np.min(r))))
        except:
            min_res.append(0)
    res_name = "NTD"
    residue = 123
    lst_min_time.append(min_res)
    lst_max_time.append(max_res)
with open('all_residence_time_from_python.dat', 'w') as f:
    #in this BSA study I am recalling resid which was printed by the 
    f.write('#resid resname residue | min_time max_time mean SD | ')
    for f_dir in lst_dir:
        f.write('{} '.format(f_dir))
    for i, val in enumerate(res):
        f.write('\n{:>3} {} {:>3} '.format(i, res_name, residue))
        for min_t, max_t, mn, sd in zip(lst_min_time, lst_max_time, lst_mean, lst_std):
            f.write('{:6.3f} {:8.3f} {:8.3f} {:8.3f} '.format(float(min_t[i]), float(max_t[i]), mn[i], sd[i]))
# print individual file in each directory with similar to a file resinfo with a cutoff
f2 = open('all_filtered_residence_time_from_python.dat', 'w')
f2.write('#resid resname residue | min_time max_time mean SD\n')
for i, f_dir in enumerate(lst_dir):
    file = "ana_md/contact/%s"%(outfile)
    with open('%s/%s'%(f_dir, file), 'w') as f:
        print("\nprinting a file on {}".format(f_dir))
        f.write('#resid resname residue | min_time max_time mean SD')
        lst_filtered_res = np.where(np.array(lst_max_time[i]) > (float(lst_tot_time[i]) * cut_percentage))
        for j in lst_filtered_res[0]:
            f.write('\n{:>3} {} {:>3} '.format(j, res_name, residue))
            f2.write('\n{:>3} {} {:>3} '.format(j, res_name, residue))
            f.write('{:6.3f} {:8.3f} {:8.3f} {:8.3f}'.format(float(lst_min_time[i][j]), float(lst_max_time[i][j]), lst_mean[i][j], lst_std[i][j]))
            f2.write('{} {:6.3f} {:8.3f} {:8.3f} {:8.3f}'.format(f_dir, float(lst_min_time[i][j]), float(lst_max_time[i][j]), lst_mean[i][j], lst_std[i][j]))
f2.close()
