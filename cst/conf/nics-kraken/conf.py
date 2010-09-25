"""
NICS Kraken

Install under /lustre/scratch/

Use Gir, Vim, and GNU compilers:
module load git vim
module swap PrgEnv-pgi PrgEnv-gnu

See install/install-python-kraken.sh for statically linked Python

showbf
showusage
qsub -l debugging
alias showme='showq | sed -n "/JOBID/p; /--/p; /^ /p; /$USER/p"'

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
    'f': '-fimplicit-none -Wall',
    'g': '-fbounds-check -ffpe-trap=invalid,zero,overflow -g',
    't': '-fbounds-check -ffpe-trap=invalid,zero,overflow',
    'p': '-O -pg',
    'O': '-O3',
    '8': '-fdefault-real-8',
}
cvm_ = dict(
    fortran_flags = {
        'g': '-Wall -fbounds-check -ffpe-trap=invalid,zero,overflow -g',
        'O': '-Wall -O3',
    },
)

