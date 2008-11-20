#!/bin/bash -e

#PBS -N %(code)s%(count)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -q %(queue)s
#PBS -M %(email)s
#PBS -m abe
#PBS -e stderr
#PBS -o stdout
#PBS -V

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
mpirun -machinefile $PBS_NODEFILE -np %(np)s %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

