import numpy as np
import os
import sys
import matplotlib.pyplot as plt
lst_dir = sys.argv[4:]
time_stp = float(sys.argv[1])
f_out = sys.argv[2]
f_in = sys.argv[3]
file_post = "ana_md/%s"%(f_in)
lst_res, lst_min_time, lst_max_time, lst_mean, lst_std, lst_tot_time = [], [], [], [], [], []
for f_dir in lst_dir:
    print("working on {}".format(f_dir))
    data = np.loadtxt('%s/%s'%(f_dir, file_post),skiprows=1, usecols=1)
    lst_tot_time.append(data.shape[0] * time_stp)
    print("simulation length of {}".format(data.shape[0] * time_stp))
    lst_mean.append(np.nan_to_num(np.mean(data)))
    lst_std.append(np.nan_to_num(np.std(data)))
    lst_min_time.append(np.nan_to_num(np.max(data)))
    lst_max_time.append(np.nan_to_num(np.min(data)))
with open('avg_from_python_%s.dat'%(f_out), 'w') as f:
    f.write('#fname min max mean SD ')
    for f_dir, vmin, vmax, mn, sd in zip(lst_dir, lst_min_time, lst_max_time, lst_mean, lst_std):
        print(f_dir, vmin, vmax, mn, sd )
        f.write('{} {:8.3f} {:8.3f} {:8.3f} {:8.3f}\n'.format(f_dir, vmin, vmax, mn, sd))
