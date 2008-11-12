#!/bin/bash

#PBS -N %(code)s%(count)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l mem=%(ramnode)smb
#PBS -l walltime=%(walltime)s
#PBS -q large
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -M %(email)s
#PBS -V

module load intel
module load vmpi

cd %(rundir)r

cp /cluster/mpi/tools/param.bigcluster .

echo "$( date ): %(code)s started" >> log
%(pre)s
mpirun -np %(np)s -paramfile ./param.bigcluster -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

#mv "/scratch/$dir" %(rundir)r

