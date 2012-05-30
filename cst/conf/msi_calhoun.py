"""
UMN/MSI Calhoun

http://www.msi.umn.edu/hardware/calhoun/
SGI Altix XE 1300 cluster
256 x 8 2.66 GHz Intel Xeon
16 GB
/scratch1
ulimit -s unlimited
ulimit -n 4096
vi ~/.modulerc
alias qme='qstat -u $USER'
#%Module1.0
module load intel vmpi
"""

login = 'calhoun.msi.umn.edu'
hostname = 'login1'
maxnodes = 256
maxcores = 8
maxram = 15000
maxtime = 24, 00
fortran_serial = 'ifort'
fortran_mpi = 'mpif90'

fortran_flags = {
    'f': '-u -std95 -warn',
    'g': '-CB -traceback -g',
    't': '-CB -traceback',
    'p': '-O -pg',
    'O': '-O3',
    '8': '-r8',
}

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpirun -np {nproc} -hostfile $PBS_NODEFILE {command}',
    'script':  'mpirun -np {nproc} -hostfile $PBS_NODEFILE -paramfile /cluster/mpi/tools/param.bigcluster {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

script_header = """\
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
"""

