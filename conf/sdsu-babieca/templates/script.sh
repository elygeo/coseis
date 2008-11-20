#!/bin/bash -e

#PBS -N %(code)s%(count)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s:mpi
#PBS -l walltime=%(walltime)s
#PBS -q %(queue)s
#PBS -M %(email)s
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -V

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
mpiexec -n %(np)s %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

