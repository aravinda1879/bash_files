import numpy as np
import os
import sys
import matplotlib.pyplot as plt
import gc
time_stp = float(sys.argv[1])
#cut_percentage is not using. historical reasons ;-)
cut_percentage = float(sys.argv[2])
infile1 = str(sys.argv[3])
infile2 = str(sys.argv[4])
#as of now outfile also not required
outfile = str(sys.argv[5])
index1 =  int(sys.argv[6])
index2 =  int(sys.argv[7])
#following is also not required
lst_dir = sys.argv[8:]

print(time_stp)
file = "ana_md/contact_wat/%s"%(infile2)
lst_res, lst_min_time, lst_max_time, lst_mean, lst_std, lst_tot_time = [], [], [], [], [], []
lst_total_mean, lst_total_sd = [], []
def read_pdb (f_dir,infile1) :
    residue, resid = 0, 1
    residue_index, resname_index, resid_index, segname_index = [], [], [], [] 
    with open('%s/%s'%(f_dir,infile1), 'r') as f:
        data = f.readlines()
        # data = list(map(lambda x: list( x.split()), data))
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
print(lst_dir)
for ii,f_dir in enumerate(lst_dir):
    print("\nworking on {}".format(f_dir))
    residue_index, resname_index, resid_index, segname_index = read_pdb(f_dir,infile1)
    with open('%s/%s'%(f_dir, file), 'r') as f:
        data = f.readlines()
        lst_tot_time.append(len(data) * time_stp)
        print("simulation length of {}".format(len(data) * time_stp))
        data = list(map(lambda x: list(map(int, x.split('|')[-1].split())), data))
    gc.collect()
    ntimesteps = len(data)
    nparticles = max(residue_index) + 1 #remember this is residue number. previous version based on resid
    data = [i for i in map(lambda arg: [nparticles] if arg[1] == [-1] else arg[1], enumerate(data))]
    #last n number of elements were selected to reduce the computational time.  data[-100000:-80000] for 500ns
    data = data[index1:index2]
    print("number of data %s"%(len(data)))
    tmp = list(np.bincount(d, minlength=nparticles) for d in data)
    del data
    def pad_to_length(a, length, tmp):
        z = np.zeros(length)
        z[:a.shape[0]] = a
    #    print(len(list(tmp)))
        gc.collect()
        return z
    gc.collect()
    new = np.array([pad_to_length(a, nparticles +1, tmp) for a in tmp]).T
    del tmp
    print(len(new))
    gc.collect()
    def residence_times(arr, new):
        """print(arr.shape)"""
        bounded = np.hstack(([0], arr, [0]))
        difs = np.diff(bounded)
        run_starts, = np.where(difs > 0)
        run_ends, = np.where(difs < 0)
        #print(list(new).index(arr))
        gc.collect()
        return (run_ends - run_starts) * time_stp
    res = [residence_times(a, new) for a in new]
    #lst_res.append(res)
    gc.collect()
    print("reading is done. Now calculaing average")
    flat_res_list = [item for sublist in res for item in sublist]
    lst_total_mean.append(np.nan_to_num([np.mean(flat_res_list)]))
    lst_total_sd.append(np.nan_to_num([np.std(flat_res_list)]))
    print("mean {}".format(lst_total_mean))
    print("sd {}".format(lst_total_sd))
    print("Total resident time in {} is {} with SD of {}".format(f_dir, lst_total_mean[ii], lst_total_sd[ii]))
