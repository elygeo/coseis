#!/bin/bash -e

#PBS -N {name}
#PBS -M {email}
#PBS -l nodes={nodes}:ppn={ppn}
#PBS -l walltime={walltime}
#PBS -l pmem={pmem}mb
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -V

module load intel vmpi
cd "{rundir}"
set > env
cp /cluster/mpi/tools/param.bigcluster .

echo "$( date ): {name} started" >> log
{pre}
mpirun -np {nproc} -paramfile ./param.bigcluster -hostfile $PBS_NODEFILE {command}
{post}
echo "$( date ): {name} finished" >> log

