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
    data = np.loadtxt('%s/%s'%(f_dir, file_post),skiprows=1, usecols=(1,2,3,4,5,6,7,8))
    lst_tot_time.append(data.shape[0] * time_stp)
    print("simulation length of {}".format(data.shape[0] * time_stp))
    lst_mean.append(np.nan_to_num(np.mean(data,axis=0)))
    lst_std.append(np.nan_to_num(np.std(data,axis=0)))
    lst_min_time.append(np.nan_to_num(np.min(data,axis=0)))
    lst_max_time.append(np.nan_to_num(np.max(data,axis=0)))

with open('avg_from_python_%s.dat'%(f_out), 'w') as f:
    foo = np.concatenate((lst_min_time[0], lst_max_time[0], lst_mean[0], lst_std[0]))
    template = '{:<25} '
    template1 = '{:} '
    for n, i in zip(foo, range(len(foo))):
        template += '{t[*]:>20.3f} '.replace('*', str(i))
        template1 += '{t[*]} '.replace('*', str(i))
    template += '\n'
    template1 += ''
    #print(template)
    f.write('#fname min max mean SD (Iz Iy Ix l1 l2  rel_shape_anisotropy aspectR_ZY aspectR_ZX) \n')
    for f_dir, vmin, vmax, mn, sd in zip(lst_dir, lst_min_time, lst_max_time, lst_mean, lst_std):
        #print(f_dir, vmin, vmax, mn, sd )
        #print('{t[0]} {t[1]} {t[2]} {t[3]} {t[4]} {t[5]} {t[6]}'.format( t=vmin ))
        print(template1.format(f_dir, t=np.concatenate( (vmin, vmax, mn, sd))))
        f.write(template.format(f_dir, t=np.concatenate( (vmin, vmax, mn, sd))))

        #f.write('{}'.format(f_dir)+(' {:8.3f}'*28).format((map(float, x) for x in vmin), (map(float, x) for x in vmax), (map(float, x) for x in mn), (map(float, x) for x in sd))+'/n')
