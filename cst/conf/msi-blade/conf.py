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
"""
login = 'blade.msi.umn.edu'
hostname = 'blade28[5678]'
maxcores = 4;
maxram = 7000
queue_opts = [
    {'queue': 'devel', 'maxnodes': 16,  'maxtime': (1, 00)},
    {'queue': 'bc',    'maxnodes': 268, 'maxtime': (48, 00)},
]
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpirun -np {nproc} -hostfile mf {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}
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

