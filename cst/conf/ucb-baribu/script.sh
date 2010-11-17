#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -e %(rundir)s/%(name)s-err
#PBS -o %(rundir)s/%(name)s-out
#PBS -m abe
#PBS -V
#PBS -r n

export -n PBS_ENVIRONMENT
set > env
cd "%(rundir)s"

echo "$( date ): %(name)s started" >> log
%(pre)s
mpirun -hostfile $PBS_NODEFILE %(command)s
%(post)s
echo "$( date ): %(name)s finished" >> log

