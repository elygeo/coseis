#!/bin/bash -e

##PBS -A TG-MCA03S012
#PBS -N %(name)s
#PBS -M %(email)s
#PBS -l size=%(totalcores)s
#PBS -l walltime=%(walltime)s
#PBS -e %(rundir)s/stderr
#PBS -o %(rundir)s/stdout
#PBS -m abe
#PBS -V

cd "%(rundir)s"

echo "$( date ): %(name)s started" >> log
%(pre)s
/usr/bin/time -p aprun -n %(nproc)s %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

