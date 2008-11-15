#!/bin/bash -e

#PBS -N %(code)s%cound)s
#PBS -l nodes=%(nodes):ppn=%(ppn)
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -M %(email)s
#PBS -V
#PBS -r n

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
export -n PBS_ENVIRONMENT
mpirun -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

