#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -e %(rundir)s/stderr
#PBS -o %(rundir)s/stdout
#PBS -m abe
#PBS -V

cd "%(rundir)s"

echo "$( date ): %(name)s started" >> log
%(pre)s
mpiexec -np %(nproc)s -machinefile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

