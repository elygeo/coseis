#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -l pmem=%(pmem)smb
#PBS -e %(rundir)s/stderr
#PBS -o %(rundir)s/stdout
#PBS -m abe
#PBS -V
module load intel vmpi

cd "%(rundir)s"
cp /cluster/mpi/tools/param.bigcluster .

echo "$( date ): %(name)s started" >> log
%(pre)s
mpirun -np %(nproc)s -paramfile ./param.bigcluster -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

