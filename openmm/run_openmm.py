from simtk.openmm.app import *
from simtk.openmm import *
from simtk.unit import *
from sys import stdout
import numpy as np
#import gc

psf  = CharmmPsfFile('A_AICHI_68_10ps_wb.psf')
pdb  = PDBFile('A_AICHI_68_10ps_wb.pdb')
temp = 300

#Simulation parameter files
params = CharmmParameterSet('par_all36_carb.prm','par_all36_prot.prm','toppar_all36_carb_glycopeptide.str','toppar_water_ions.str')

#Get Periodic Box size
#minx = min([i[0]*1/nanometer for i in pdb.getPositions()])
#print(pdb.getPositions()[0])
#maxx = max([i[0]*1/nanometer for i in pdb.getPositions()])
#print(minx,maxx)
#miny = min([i[1]*1/nanometer for i in pdb.getPositions()])
#maxy = max([i[1]*1/nanometer for i in pdb.getPositions()])
#minz = min([i[2]*1/nanometer for i in pdb.getPositions()])
#maxz = max([i[2]*1/nanometer for i in pdb.getPositions()])
#print("box size is x={} y={} z={}".format(maxx-minx,maxy-miny,maxz-minz))
#Define Periodic Box size
#psf.setBox((maxx-minx)*nanometers, (maxy-miny)*nanometers, (maxz-minz)*nanometers)
#psf.setBox(15.0*nanometers, 15.0*nanometers, 15.0*nanometers)
xyz = np.array(pdb.positions/nanometer)
xyz[:,0] -= np.amin(xyz[:,0])
xyz[:,1] -= np.amin(xyz[:,1])
xyz[:,2] -= np.amin(xyz[:,2])
pdb.position = xyz*nanometer

print(np.amax(xyz[:,0]),np.amax(xyz[:,1]))

psf.setBox(15.0*nanometers, 15.0*nanometers, 15.0*nanometers)

# System Configuration
nonbondedMethod = PME
nonbondedCutoff = 1.2*nanometers
switchDistance  = 1.0*nanometer
ewaldErrorTolerance = 0.0005
constraints = HBonds
rigidWater = True
constraintTolerance = 0.000001

# Integration Options
dt = 0.002*picoseconds
temperature = temp*kelvin
friction = 1.0/picosecond
pressure = 1.0*atmospheres
barostatInterval = 25

# Simulation Options;
equilibrationSteps = 2
platform = Platform.getPlatformByName('CUDA')
platformProperties = {'Precision': 'mixed'}
#dcdReporter = DCDReporter('prod.dcd', 1)
#dataReporter = StateDataReporter('log.txt', 1, totalSteps=steps, step=True, speed=True, progress=True, potentialEnergy=True, temperature=True, separator='\t')


#positional restrain
restraints = openmm.CustomExternalForce("k*((x-x0)^2+(y-y0)^2+(z-z0)^2)")
restraints.addGlobalParameter("k", 500.0*kilocalories_per_mole/angstroms**2)
restraints.addPerParticleParameter("x0")
restraints.addPerParticleParameter("y0")
restraints.addPerParticleParameter("z0")
atoms = list(pdb.topology.atoms())
for i, atom_crd in enumerate(pdb.positions):
    if atoms[i].name in ('CA', 'C', 'N'):
        restraints.addParticle(i, atom_crd)

# Prepare the Simulation in NPT
print('Building system in NPT...')
system = psf.createSystem(params, nonbondedMethod=nonbondedMethod, nonbondedCutoff=nonbondedCutoff, switchDistance=switchDistance, constraints=constraints, rigidWater=rigidWater, ewaldErrorTolerance=ewaldErrorTolerance, removeCMMotion=True)
system.addForce(restraints)
system.addForce(MonteCarloBarostat(pressure, temperature, barostatInterval))
integrator = LangevinIntegrator(temperature, friction, dt)
integrator.setConstraintTolerance(constraintTolerance)
system.addForce(AndersenThermostat(temp*kelvin, friction))
simulation = Simulation(psf.topology, system, integrator, platform)
#simulation = Simulation(psf.topology, system, integrator)
simulation.context.setPositions(pdb.positions)
print('Simulation building is done')



#1st minimization with fixed backbone
simulation.minimizeEnergy(maxIterations=10000)
simulation.reporters.append(DCDReporter('A_AICHI_68_wb_10ps_min_1.dcd', 5000))
simulation.reporters.append(StateDataReporter('A_AICHI_68_wb_10ps_min_1.log', 50, step=True, potentialEnergy=True, temperature=True, kineticEnergy=True,totalEnergy=True, volume=True, time=True))
simulation.reporters.append(CheckpointReporter('A_AICHI_68_wb_10ps_min_1.chk', 5000))
#positions = simulation.context.getState(getPositions=True).getPositions()
#PDBFile.writeFile(simulation.topology, positions, open('lowtempex.pdb', 'w'))
print("Starting energy minimization")
simulation.step(10000)
print("Finish minimization step 1")



#2nd minimization without fixed backbone
simulation.context.setParameter("k", 0*kilojoules/mole/nanometer**2)
simulation.minimizeEnergy(maxIterations=10000)
simulation.reporters.append(DCDReporter('A_AICHI_68_wb_10ps_min_2.dcd', 5000))
simulation.reporters.append(StateDataReporter('A_AICHI_68_wb_10ps_min_2.log', 5000, step=True, potentialEnergy=True, temperature=True, kineticEnergy=True,totalEnergy=True, volume=True, time=True))
simulation.reporters.append(CheckpointReporter('A_AICHI_68_wb_10ps_min_2.chk', 5000))
#positions = simulation.context.getState(getPositions=True).getPositions()
#PDBFile.writeFile(simulation.topology, positions, open('lowtempex.pdb', 'w'))
simulation.step(10000)

#NVT heating
platform = Platform.getPlatformByName('CUDA')
platformProperties = {'Precision': 'mixed'}

#simulation.context.setParameter("k", 10*kilojoules/mole/nanometer**2)
for x in np.linspace(1,temp,10):
    tt = x * u.kelvin
    print('Running the simulation in NVT at {}'.format(x))
    simulation.reporters.append(DCDReporter('A_AICHI_68_wb_10ps_heat.dcd', 5000))
    simulation.reporters.append(StateDataReporter('A_AICHI_68_wb_10ps_heat.log', 5000, step=True, potentialEnergy=True, temperature=True, kineticEnergy=True,totalEnergy=True, density=True, time=True))
    simulation.reporters.append(CheckpointReporter('A_AICHI_68_wb_10ps_heat.chk', 5000))
    simulation.context.setParameter(AndersenThermostat.Temperature(), tt)
    #simulation.context.setVelocitiesToTemperature(tt)
    simulation.step(25000)

#NPT 1ns for density relaxation
system.addForce(MonteCarloBarostat(pressure, temp, barostatInterval))
print('Running the simulation in NPT')
simulation.reporters.append(DCDReporter('A_AICHI_68_wb_10ps_md0.dcd', 5000))
simulation.reporters.append(StateDataReporter('A_AICHI_68_wb_10ps_md0.log', 5000, step=True, potentialEnergy=True, temperature=True, kineticEnergy=True,totalEnergy=True, density=True, time=True))
simulation.reporters.append(CheckpointReporter('A_AICHI_68_wb_10ps_md0.chk', 5000))
simulation.step(500000)
print('done')
    

