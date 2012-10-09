#!/bin/bash -e

#$ -A {account}
#$ -N {name}
#$ -M {email}
#$ -q {queue}
#$ -pe {ppn}way {totalcores}
#$ -l h_rt={walltime}
#$ -e {rundir}/{name}.err
#$ -o {rundir}/{name}.out
#$ -m n
#$ -V
#$ -wd {rundir}

export MY_NSLOTS={nproc}

cd "{rundir}"
env >> {name}.env

lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d {iodir} ] && lfs setstripe -c {nstripe} {iodir}
[ {nproc} -gt 4000 ] && cache_binary $PWD {command}

echo "$( date ): {name} started" >> {name}.out
{pre}
{launch}
{post}
echo "$( date ): {name} finished" >> {name}.out

