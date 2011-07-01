"""
USC Earth Science cluster

alias qdev='qsub -I -l nodes=1,walltime=2:00:00'
"""

login = hostname = 'geosys.usc.edu'
maxnodes = 24
maxcores = 2
maxram = 1800
fortran_serial = 'gfortran'
fortran_mpi = 'mpif90'
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'qsub -I "%(name)s.sh"',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -W depend="afterok:%(depend)s" "%(name)s.sh"',
}

