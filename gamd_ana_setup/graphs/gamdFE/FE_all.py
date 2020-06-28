import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from pylab import figure, axes, pie, title, show
import matplotlib.image as mpimg
import matplotlib.lines as mlines
from collections import OrderedDict
import scipy.stats as stats

main_dir = "/scratch3/aravinda1879/zwitterionic_gamd"
sl_lst = [ 0.0, 0.3, 1.0, 2.0, 3.0, 5.0]
#sl_lst = [ 0.0 ]
pol_lst=[ "pCBMA" ]
fol_lst     = []
infile_lst  = ["pmf-c2-2d_rg_B_polymer_com_B_c2_c2_4gamdFE"]
outfile_lst = ["2d_rg_e2e_bin10"]
color=['k','b','r','g','yellow','darkblue','purple','lime','teal','gray','orange','sienna','y']
graph_lst   = []
#lx, ly, lz  = [], [], []
data        = {}
T = 310.5

for pol in pol_lst:
    for i in range(5,6):
        for sl in sl_lst:
            fol_lst.append("{}/{}n{}_18_ata_{}M_{}K_gamd_10ps".format(main_dir,pol,i,sl,T) )
for infile in infile_lst:
    for fol in fol_lst:
        graph_lst.append("{}/ana_gamd/{}.xvg".format(fol, infile))

for index, graph in enumerate(graph_lst):
    #lx, ly, lz  = [], [], []
    print('reading data from: {}'.format(graph))
    lx, ly, lz = np.loadtxt(graph, skiprows = 5, unpack = True,
                            usecols=(1,0,2), dtype=np.float32)
    x=np.unique(lx)
    y=np.unique(ly)
    Z = lz[::-1].reshape(len(y),len(x))
    print(len(lz),len(x),len(y))
    with open('test', 'w') as f1:
        f1.write("{}".format(x))
        f1.write("\n")
        f1.write("{}".format(y))
        f1.write("{}".format(lz))
        f1.write("\n")
        f1.write("\n")
        f1.write("{}".format(Z))

    X, Y = np.meshgrid(x,y)
    Z = lz.reshape(len(y),len(x))
    data["{}".format(outfile_lst[0])] = [X, Y, Z]
    sns.set(font_scale=2, style="ticks")
    fig, ax = plt.subplots(ncols=1)
    fig.set_size_inches(26.0, 13.0)
    plt.xlabel('end to end ($\AA$)')
    plt.ylabel('Rg ($\AA$)')
    #plt.xlim(0, 300)
    #plt.ylim(060)
    #plt.ylim(ymin=0)
    #i=0
    #print(ldata.items())
    #for k,v in data.items():
    #    vt=v
        #print(vt)
    cs = ax.contourf(x, y, Z,alpha=0.5)
    contours=ax.contour(x, y, Z)
    plt.clabel(contours,inline=True, fontsize=8)
    # i += 1
    plt.colorbar(cs)
    ##plt.legend(sl_lst,handletextpad=0.0, handlelength=1.0, fontsize=15,
     #          loc='upper center', fancybox=True, shadow=True, ncol=6)
    plt.savefig('2d_rg_e2e_{}5_{}.png'.format(pol_lst[0],sl_lst[index]),bbox_inches='tight',format='png')
    ax.clear()





