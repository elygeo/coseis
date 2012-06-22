#!/bin/bash

#PBS -A {account}
#PBS -N {name}
#PBS -M {email}
#PBS -l size={totalcores}
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}.error
#PBS -o {rundir}/{name}.output
#PBS -m n

cd "{rundir}"
env >> {name}.env

lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d hold ] && lfs setstripe -c {nstripe} hold

echo "$( date ): {name} started" >> {name}.log
{pre}
{launch}
{post}
echo "$( date ): {name} finished" >> {name}.log

