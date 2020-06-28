from prody import *
from pylab import *
import re

in_psf=str(sys.argv[1])
ana_time=int(sys.argv[2])
lst_dcd = sys.argv[3:]
out_file = "pca_CA_eign_val.dat"

#loading the psf and trajectories
structure = parsePSF(in_psf)
trajectory_all = Trajectory(lst_dcd[0])
#lst_dcd.pop(0)
#for fdcd in lst_dcd:
#    trajectory_all.addFile(fdcd)

#extract final ns (second variable)
#for i in trajectory_all.getFilenames():
#    m = re.search('(\d+?)ps',i)
#    ts = int(m.group(1))
#
#ini_frm = int(len(trajectory_all) - (ana_time*1000/ts))
#print(ini_frm)

trajectory = trajectory_all
trajectory.link(structure)
trajectory.setCoords(structure)
trajectory.setAtoms(structure.calpha)

eda_trajectory = EDA('MDM2 Trajectory')
eda_trajectory.buildCovariance( trajectory )
eda_trajectory.calcModes()

print("Finished calculating modes")

saveModel(eda_trajectory)

#Only saving first 3 modes
writeNMD('mdm2_eda.nmd', eda_trajectory[:3], structure.select('calpha'))

y_lst = list(eda_trajectory.getEigvals())

with open('%s'%(out_file), 'w') as tmp:
    for i, t in enumerate(y_lst):
        tmp.write('{} {}\n'.format((i+1),str(t)))
tmp.close()
print("Eigen values were printed")






