#!/bin/bash -e

#$ -A {account}
#$ -N {name}
#$ -M {email}
#$ -q {queue}
#$ -pe {maxcores}way {totalcores}
#$ -l h_rt={walltime}
#$ -e {rundir}/{name}-err
#$ -o {rundir}/{name}-out
#$ -m abe
#$ -V
#$ -wd {rundir}

export MY_NSLOTS={nproc}
cd "{rundir}"
set > env
lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d hold ] && lfs setstripe -c {nstripe} hold
[ {nproc} -gt 4000 ] && cache_binary $PWD {command}

echo "$( date ): {name} started" >> log
{pre}
ibrun {command}
{post}
echo "$( date ): {name} finished" >> log

