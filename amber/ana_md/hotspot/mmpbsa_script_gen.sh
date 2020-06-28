#!/bin/bash
comdir="../../allnc"
source ../../var_list.sh
cat << EOF > script_$1
#!/bin/bash
#SBATCH --qos=colina-b
#SBATCH --job-name=be_${fname}_run_${1}
#SBATCH -o testjob.out
#SBATCH -e testjob.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ara879@gmail.com
#SBATCH -t 03-01:00:00
#SBATCH --mem-per-cpu=6gb
#SBATCH --nodes=5
#SBATCH --ntasks=10

module load intel/2016.0.109 openmpi/1.10.2 amber/14


cd \$SLURM_SUBMIT_DIR

echo Host = \`hostname\`
echo Date = \`date\`


mpiexec  MMPBSA.py.MPI -O -i mmpbsa_${1}_0.in  -o final_be_${1}_0.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -mc new$mcptop  -mr new$mrptop  -y ${comdir}/${nc_com}_5ps_strip_h2o_ion.mdcrd   > progress_${1}_0.log 2>&1 
mpiexec  MMPBSA.py.MPI -O -i mmpbsa_${1}_1.in  -o final_be_${1}_1.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -mc new$mcptop  -mr new$mrptop  -y ${comdir}/${nc_com}_5ps_strip_h2o_ion.mdcrd   > progress_${1}_1.log 2>&1 
mpiexec  MMPBSA.py.MPI -O -i mmpbsa_${1}_2.in  -o final_be_${1}_2.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -mc new$mcptop  -mr new$mrptop  -y ${comdir}/${nc_com}_5ps_strip_h2o_ion.mdcrd   > progress_${1}_2.log 2>&1 
mpiexec  MMPBSA.py.MPI -O -i mmpbsa_${1}_3.in  -o final_be_${1}_3.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -mc new$mcptop  -mr new$mrptop  -y ${comdir}/${nc_com}_5ps_strip_h2o_ion.mdcrd   > progress_${1}_3.log 2>&1 
mpiexec  MMPBSA.py.MPI -O -i mmpbsa_${1}_4.in  -o final_be_${1}_4.dat -cp ../new$cptop -rp ../new$rptop -lp ../new$lptop -mc new$mcptop  -mr new$mrptop  -y ${comdir}/${nc_com}_5ps_strip_h2o_ion.mdcrd   > progress_${1}_4.log 2>&1 
rm _*
EOF

cat << EOF >> ../run_list.sh
cd ${1}
sbatch script_${1}
cd ..
EOF

