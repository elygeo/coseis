#!/bin/bash -e

#$ -N %(code)s%(count)s
#$ -pe %(maxcores)sway %(totalcores)s
#$ -l h_rt=%(walltime)s
#$ -q %(queue)s
#$ -M %(email)s
#$ -m abe
#$ -e stderr
#$ -o stdout
#$ -V
#$ -wd %(rundir)s
export MY_NSLOTS=%(np)s

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
/usr/bin/time -p ibrun %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

