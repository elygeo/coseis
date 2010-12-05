"""
NICS Kraken

Install under /lustre/scratch/

Use Git and Vim:
module load git vim

See install/install-python-kraken.sh for statically linked Python

showq
showbf
showusage
qsub -l debugging
alias showme='qstat -u $USER'

Home directories have a 2 GB quota.
CrayPAT (Cray Performance Analysis Tools) is useful for profiling and
collecting hardware performance data
"""
login = 'kraken-pwd.nics.utk.edu'
hostname = 'kraken-pwd[1234]'
maxram = 15000
maxcores = 12
maxnodes = 8256
maxtime = 24, 00
rate = 1e6
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -W depend="afterok:%(depend)s" "%(name)s.sh"',
}
fortran_serial = 'ftn'
fortran_mpi = 'ftn'
fortran_flags = {
    'f': '-Mdclchk',
    'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
    't': '-Ktrap=fp -Mbounds',
    'p': '-pg -Mprof=func',
    'O': '-fast',
    '8': '-Mr8',
}
cvm_ = dict(
    fortran_flags = {
        'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
        'O': '-fast',
    },
)

