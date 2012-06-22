#!/bin/bash -e

#PBS -N {name}
#PBS -M {email}
#PBS -q {queue}
#PBS -l nodes={nodes}:ppn={ppn}:mpi
#PBS -l walltime={walltime}
#PBS -e {rundir}/{code}.error
#PBS -o {rundir}/{code}.output
#PBS -m n
#PBS -V

cd "{rundir}"
env > {code}.env

echo "$( date ): {code} started" >> {code}.log
{pre}
{launch}
{post}
echo "$( date ): {code} finished" >> {code}.log

