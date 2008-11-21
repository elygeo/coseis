#!/bin/bash -e

#$ -M %(email)s
#$ -N %(name)s
#$ -q %(queue)s
#$ -pe %(maxcores)sway %(totalcores)s
#$ -l h_rt=%(walltime)s
#$ -e stderr
#$ -o stdout
#$ -m abe
#$ -V
#$ -wd %(rundir)s
export MY_NSLOTS=%(np)s

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
/usr/bin/time -p ibrun %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

