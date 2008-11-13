#!/bin/bash

#$ -N %(code)s%(count)s
#$ -pe %(ppn)sway %(np)s
#$ -l h_rt=%(walltime)s
#$ -q normal
#$ -e stderr
#$ -o stdout
#$ -m abe
#$ -M %(email)s
#$ -V

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
/usr/bin/time -p ibrun -np %(np)s %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

