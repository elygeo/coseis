#!/bin/bash -e

#PBS -A {account}
#PBS -N {name}
#PBS -M {email}
#PBS -l size={totalcores}
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe

cd "{rundir}"
env > {name}-env

lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d hold ] && lfs setstripe -c {nstripe} hold

echo "$( date ): {name} started" >> {name}-log
{pre}
{launch_command}
{post}
echo "$( date ): {name} finished" >> {name}-log

