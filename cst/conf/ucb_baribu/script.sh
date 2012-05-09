#!/bin/bash -e

#PBS -N {name}
#PBS -M {email}
#PBS -l nodes={nodes}:ppn={ppn}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -V
#PBS -r n

export -n PBS_ENVIRONMENT
set > env
cd "{rundir}"

echo "$( date ): {name} started" >> log
{pre}
mpirun -hostfile $PBS_NODEFILE {command}
{post}
echo "$( date ): {name} finished" >> log

