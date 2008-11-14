#!/bin/bash -e

#PBS -N %(code)s%(count)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -q mpi
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -M %(email)s
#PBS -V

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
mpiexec -np %(np)s -machinefile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

