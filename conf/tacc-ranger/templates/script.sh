#!/bin/bash -e

#$ -N %(code)s%(count)s
#$ -pe %(cores)sway %(totalcores)s
#$ -l h_rt=%(walltime)s
#$ -q serial
##$ -q development
##$ -q normal
##$ -q large
#$ -e %(rundir)sstderr
#$ -o %(rundir)sstdout
#$ -m abe
#$ -M %(email)s
#$ -V
#$ -cwd

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
/usr/bin/time -p ibrun -np %(np)s %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

