#!/bin/bash -e

#$ -N %(code)s%(count)s
#$ -pe %(cores)sway %(totalcores)s
#$ -l h_rt=%(walltime)s
#$ -q %(queue)s
#$ -e stderr
#$ -o stdout
#$ -m abe
#$ -M %(email)s
#$ -V
#$ -wd %(rundir)s
export MY_NSLOTS=%(np)s

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
/usr/bin/time -p ibrun %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

