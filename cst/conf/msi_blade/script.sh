#!/bin/bash -l

#PBS -N {name}
#PBS -M {email}
#PBS -q {queue}
#PBS -l nodes={nodes}:ppn={ppn}
#PBS -l walltime={walltime}
#PBS -l pmem={pmem}mb
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -V

#module load pathmpi
#module load intelmpi
module load intel
module load vmpi/intel
cd "{rundir}"
set > env

echo "$( date ): {name} started" >> log
{pre}
mpirun -np {nproc} -hostfile $PBS_NODEFILE {command}
{post}
echo "$( date ): {name} finished" >> log

