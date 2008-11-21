#!/bin/bash -l

#PBS -N %(name)s%(count)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
#PBS -l mem=%(ram)smb
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -V

#module load pathmpi
module load intelmpi

cd %(rundir)r

echo "$( date ): %(name)s started" >> log
%(pre)s
mpirun -np %(np)s -hostfile $PBS_NODEFILE %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

