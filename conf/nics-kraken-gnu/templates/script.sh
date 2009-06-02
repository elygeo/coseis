#!/bin/bash

##PBS -A TG-MCA03S012
#PBS -N %(name)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l size=%(totalcores)s
#PBS -l walltime=%(walltime)s
##PBS -l feature=2gbpercore
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -V

cd %(rundir)r

echo "$( date ): %(name)s started" >> log
%(pre)s
/usr/bin/time -p aprun -n %(np)s %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

