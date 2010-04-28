#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -V
#PBS -r n

cd %(rundir)r

echo "$( date ): %(name)s started" >> log
%(pre)s
export -n PBS_ENVIRONMENT
mpirun -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

