"""
UMN/MSI Blade

http://www.msi.umn.edu/hardware/blade/
IBM Bladecenter Linux cluster
268 x 2 dual-core 2.6 GHz AMD Opteron
8 GB
/scratch1
/scratch2
alias qme='qstat -u $USER'

.bashrc
ulimit -s unlimited
ulimit -n 4096

~/.modulerc
#%Module1.0
module load intelmpi

machinefile:
blade285
blade285
blade285
blade285
blade286
blade286
blade286
blade286
blade287
blade287
blade287
blade287
blade288
blade288
blade288
blade288
"""

login = 'blade.msi.umn.edu'
hostname = 'blade28[5678]'
maxcores = 4;
maxram = 7000

queue_opts = [
    ('devel', {'maxnodes': 16,  'maxtime': (1, 00)}),
    ('bc',    {'maxnodes': 268, 'maxtime': (48, 00)}),
]

fortran_serial = 'ifort'
fortran_mpi = 'mpif90'

fortran_flags = {
    'f': '-u -std95 -warn',
    'g': '-CB -traceback -g',
    't': '-CB -traceback',
    'p': '-O -pg',
    'O': '-ipo -O3 -no-prec-div',
    '8': '-r8',
}

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpirun -np {nproc} -hostfile $HOME/machinefile {command}',
    'script':  'mpirun -np {nproc} -hostfile $PBS_NODEFILE {command}'
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

script_header = """\
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
module load intel
module load vmpi/intel
"""

