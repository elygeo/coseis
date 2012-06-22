#!/bin/bash

#PBS -A {account}
#PBS -N {name}
#PBS -M {email}
#PBS -l size={totalcores}
#PBS -l walltime={walltime}
#PBS -e {rundir}/{code}.error
#PBS -o {rundir}/{code}.output
#PBS -m n

cd "{rundir}"
env >> {code}.env

lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d hold ] && lfs setstripe -c {nstripe} hold

echo "$( date ): {code} started" >> {code}.log
{pre}
{launch}
{post}
echo "$( date ): {code} finished" >> {code}.log

