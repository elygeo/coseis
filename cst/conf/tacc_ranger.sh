#!/bin/bash -e

#$ -A {account}
#$ -N {name}
#$ -M {email}
#$ -q {queue}
#$ -pe {maxcores}way {totalcores}
#$ -l h_rt={walltime}
#$ -e {rundir}/{name}.error
#$ -o {rundir}/{name}.output
#$ -m abe
#$ -V
#$ -wd {rundir}

export MY_NSLOTS={nproc}

cd "{rundir}"
env >> {name}.env

lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d hold ] && lfs setstripe -c {nstripe} hold
[ {nproc} -gt 4000 ] && cache_binary $PWD {command}

echo "$( date ): {name} started" >> {name}.log
{pre}
{launch_command}
{post}
echo "$( date ): {name} finished" >> {name}.log

