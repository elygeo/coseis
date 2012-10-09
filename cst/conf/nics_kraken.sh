#!/bin/bash

#PBS -A {account}
#PBS -N {name}
#PBS -M {email}
#PBS -l size={totalcores}
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}.err
#PBS -o {rundir}/{name}.out
#PBS -m n

cd "{rundir}"
env >> {name}.env

lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d {iodir} ] && lfs setstripe -c {nstripe} {iodir}

echo "$( date ): {name} started" >> {name}.out
{pre}
{launch}
{post}
echo "$( date ): {name} finished" >> {name}.out

