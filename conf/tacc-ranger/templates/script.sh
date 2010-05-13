#!/bin/bash -e

#$ -N %(name)s
#$ -M %(email)s
#$ -q %(queue)s
#$ -pe %(maxcores)sway %(totalcores)s
#$ -l h_rt=%(walltime)s
#$ -e %(rundir)s/stderr
#$ -o %(rundir)s/stdout
#$ -m abe
#$ -V
#$ -wd %(rundir)s

export MY_NSLOTS=%(nproc)s

cd "%(rundir)s"

echo "$( date ): %(name)s started" >> log
%(pre)s
cache_binary $PWD ./%(bin)s
/usr/bin/time -p ibrun %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

