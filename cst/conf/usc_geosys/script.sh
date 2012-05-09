#!/bin/bash -e

#PBS -N {name}
#PBS -M {email}
#PBS -l nodes={nodes}:ppn={ppn}
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -q mpi
#PBS -V

cd "{rundir}"
set > env

echo "$( date ): {name} started" >> log
{pre}
#mpiexec -n {nproc} -machinefile $PBS_NODEFILE {command}
mpiexec -n {nproc} {command}
{post}
echo "$( date ): {name} finished" >> log

