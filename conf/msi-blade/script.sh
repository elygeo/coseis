#!/bin/bash -l

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -l pmem=%(pmem)smb
#PBS -e %(rundir)s/stderr
#PBS -o %(rundir)s/stdout
#PBS -m abe
#PBS -V
#module load pathmpi
#module load intelmpi
module load intel
module load vmpi/intel

cd "%(rundir)s"

echo "$( date ): %(name)s started" >> log
%(pre)s
mpirun -np %(nproc)s -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

