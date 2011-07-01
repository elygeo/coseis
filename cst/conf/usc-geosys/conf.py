"""
USC Earth Science compute cluster

alias qdev='qsub -I -q mpi'
alias qme='qstat -u ${USER}'
"""

login = hostname = 'geosys.usc.edu'
maxnodes = 64
maxcores = 2
maxram = 1800
fortran_serial = 'gfortran'
fortran_mpi = 'mpif90'
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'mpiexec -n %(nproc)s %(command)s',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -W depend="afterok:%(depend)s" "%(name)s.sh"',
}

