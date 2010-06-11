notes = """
NICS Kraken

module swap PrgEnv-pgi PrgEnv-gnu

EPD version: rh3-x86_64
Compute nodes require statically-compiled Python.
See extras/intall/python-install-cnl.sh

/lustre/scratch/$USER
module
showusage
qsub -l debugging
showbf
alias showme='showq | sed -n "/JOBID/p; /--/p; /^ /p; /$USER/p"'

vim .bashrc

Home directories have a 2 GB quota.
CrayPAT (Cray Performance Analysis Tools) is useful for profiling and
collecting hardware performance data

account: TG-MCA03S012
"""
login = 'kraken-pwd.nics.utk.edu'
hosts = 'kraken-pwd3',
maxram = 15000
maxcores = 12
maxnodes = 8256
maxtime = 24, 00
fortran_serial = 'ftn',
fortran_mpi = 'ftn',
sord_ = dict(
    rate = 1e6, # just a guess
    fortran_flags = {
        'f': ('-fimplicit-none', '-Wall'),
        'g': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g'),
        't': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow'),
        'p': ('-O', '-pg'),
        'O': ('-O3',),
        '8': ('-fdefault-real-8',),
    },
)
cvm_ = dict(
    fortran_flags = {
        'g': ('-Wall', '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g'),
        'O': ('-Wall', '-O3'),
    },
)
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -W depend="afterok:%(depend)s" "%(name)s.sh"',
}

