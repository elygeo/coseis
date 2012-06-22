#!/bin/bash -e

#$ -A {account}
#$ -N {name}
#$ -M {email}
#$ -q {queue}
#$ -pe {ppn}way {totalcores}
#$ -l h_rt={walltime}
#$ -e {rundir}/{code}.error
#$ -o {rundir}/{code}.output
#$ -m n
#$ -V
#$ -wd {rundir}

export MY_NSLOTS={nproc}

cd "{rundir}"
env >> {code}.env

lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d hold ] && lfs setstripe -c {nstripe} hold
[ {nproc} -gt 4000 ] && cache_binary $PWD {command}

echo "$( date ): {code} started" >> {code}.log
{pre}
{launch}
{post}
echo "$( date ): {code} finished" >> {code}.log

