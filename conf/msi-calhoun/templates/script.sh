#!/bin/bash -e

#PBS -N %(name)s%(count)s
#PBS -M %(email)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -l mem=%(ram)smb
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -V

module load intel vmpi

cd %(rundir)r
cp /cluster/mpi/tools/param.bigcluster .

echo "$( date ): %(name)s started" >> log
%(pre)s
mpirun -np %(np)s -paramfile ./param.bigcluster -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

#mv "/scratch/$dir" %(rundir)r

