#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s:mpi
#PBS -l walltime=%(walltime)s
#PBS -e %(rundir)s/%(name)s-stderr
#PBS -o %(rundir)s/%(name)s-stdout
#PBS -m abe
#PBS -V

cd "%(rundir)s"
set > env

echo "$( date ): %(name)s started" >> log
%(pre)s
mpiexec -n %(nproc)s %(command)s
%(post)s
echo "$( date ): %(name)s finished" >> log

