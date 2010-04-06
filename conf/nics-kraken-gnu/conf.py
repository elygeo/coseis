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
minnodes = 1
maxnodes = 8256
maxtime = 24, 00
rate = 1e6 # just a guess
fortran_serial = 'ftn',
fortran_mpi = 'ftn',
_ = '-fimplicit-none', '-Wall', '-o'
fortran_flags = {
    'g': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g') + _,
    't': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow') + _,
    'p': ('-O', '-pg') + _,
    'O': ('-O3',) + _,
}

