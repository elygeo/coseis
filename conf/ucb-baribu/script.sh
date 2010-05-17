#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -e %(rundir)s/stderr
#PBS -o %(rundir)s/stdout
#PBS -m abe
#PBS -V
#PBS -r n
export -n PBS_ENVIRONMENT

cd "%(rundir)s"

echo "$( date ): %(name)s started" >> log
%(pre)s
mpirun -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

