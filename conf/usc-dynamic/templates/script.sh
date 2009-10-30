#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -V

cd %(rundir)r

echo "$( date ): %(name)s started" >> log
%(pre)s
mpiexec -np %(np)s -machinefile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

