#!/bin/bash -e

#$ -A %(account)s
#$ -N %(name)s
#$ -M %(email)s
#$ -q %(queue)s
#$ -pe %(maxcores)sway %(totalcores)s
#$ -l h_rt=%(walltime)s
#$ -e %(rundir)s/%(name)s-err
#$ -o %(rundir)s/%(name)s-out
#$ -m abe
#$ -V
#$ -wd %(rundir)s

export MY_NSLOTS=%(nproc)s
cd "%(rundir)s"
set > env
lfs setstripe -c 1 .
[ %(nstripe)s -ge -1 -a -d hold ] && lfs setstripe -c %(nstripe)s hold
[ %(nproc)s -gt 4000 ] && cache_binary $PWD %(command)s

echo "$( date ): %(name)s started" >> log
%(pre)s
ibrun %(command)s
%(post)s
echo "$( date ): %(name)s finished" >> log

