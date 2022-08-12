source ../namd_variables.sh
cat << EOF > watershell.dyn
! charmm
! watershell input script
!
 output {
  minwarnlev=-1
 }


 molecule{
  structure_file=${final_pdb_f%.*}.pdb
 }

 watershell {

  radii=const ! radii do not matter if with the mindist method "minimum_distance=yes" below
  radiiconst=2.0

  dasystat=yes ! this provides density equilibration, but can generally be turned off
  density_update_freq=500
  mass=file
  massfile=${final_pdb_f%.*}-mass.pdb
  massfiletype=PDB
  masscol=B

  structure_update_freq=7 ! how often the instantaneous shell surface is recomputed
!  structure_update_memory=0.9999 ! memory parameter for updating the (slowly-moving) shell surface (default 0.999)
!  distance_update_freq=
  surface_force_constant=5 ! force constant in solvent shell potential ; 1 and above seems to be reasonable
  surface_distance=0 ! thickness of solvent shell; use 0 to guess automatically
!
  rigid_body_restraint=yes
  rigid_body_force_constant=100

! use a simple minimum distance algorithm
  minimum_distance=yes

  surface_atoms="ANAME=CA" ! atoms used to define the surface ; there should not be too many
  solvent_atoms="ANAME=OH2 OR ANAME=SOD OR ANAME=CLA OR ANAME=MG" ; ! atoms used to represent solvent (there should not be too many)

  restart_file="@{restart_file}" ! these are placeholders that are populated for each run
  output_file="@{output_file}"

  output_freq=10000

 }
EOF
