"""
USC Earth Science compute cluster

.tcshrc
if ( ${?LD_LIBRARY_PATH} ) then
    setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/lib64/mpich2/lib
else
    setenv LD_LIBRARY_PATH /usr/lib64/mpich2/lib
endif

alias qdev='qsub -I -q mpi'
alias qme='qstat -u ${USER}'

geosys is Intel and compute nodes are AMD, so probably better to compile from a
compute node.
"""

login = 'geosys.usc.edu'
hostname = 'geosys.usc.edu|compute-0-[0-9]+.local'
maxnodes = 64
maxcores = 2
maxram = 1800
f2py_flags = '--fcompiler=gnu95'
fortran_serial = 'gfortran'
fortran_mpi = 'mpif90'

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpiexec -n {nproc} {command}',
    'script':  'mpiexec -n {nproc} {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

script_header = """\
#!/bin/bash -e
#PBS -N {name}
#PBS -M {email}
#PBS -l nodes={nodes}:ppn={ppn}
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -q mpi
#PBS -V
"""

