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
env > {name}-env

echo "$( date ): {name} started" >> {name}-log
{pre}
{launch_command}
{post}
echo "$( date ): {name} finished" >> {name}-log

