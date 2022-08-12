shopt -s extglob

mod=mod
for i in `seq 1 10 `; do #1
file=1eo8_${mod}${i}_noFold_conju
cd 1eo8_${mod}$i

work_file=${file}
fol=${work_file}_0.15M_300K_ws
scp -r -P 102 ${fol}/project_run* am1879@128.103.92.237:/home/am1879/md/ws/${fol}_20ps


cd ..
done
