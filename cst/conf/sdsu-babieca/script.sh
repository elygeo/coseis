#!/bin/bash -e

#PBS -N {name}
#PBS -M {email}
#PBS -q {queue}
#PBS -l nodes={nodes}:ppn={ppn}:mpi
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -V

cd "{rundir}"
set > env

echo "$( date ): {name} started" >> log
{pre}
mpiexec -n {nproc} {command}
{post}
echo "$( date ): {name} finished" >> log

