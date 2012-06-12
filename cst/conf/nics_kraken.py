"""
NICS Kraken: Cray XT5

gsissh kraken-pwd.nics.utk.edu
Install under /lustre/scratch/
CrayPAT is useful for profiling and collecting hardware performance data.

.bashrc
module swap PrgEnv-pgi PrgEnv-gnu
module load git vim yt
alias qme='qstat -u $USER'
alias qdev='qsub -I -A account_string -l size=12,walltime=2:00:00'

Useful commands:
showq
showbf
showusage

Statically linked Python:
module load yt
cd "${SCRATCHDIR}/local"
url="http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.7.1.2.tar.gz"
curl -L "${url}" | tar zx
python "virtualenv-1.7.1.2/virtualenv.py" python
. python/bin/activate
pip install pyproj
pip install GitPython
pip install readline
pip install nose
"""

maxram = 16 * 1024
maxcores = 12
maxnodes = 8 * 1024 + 64
maxtime = 24 * 60
rate = 1e6

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'aprun -n {nproc} {command}',
    'm_debug': 'totalview aprun -n {nproc} {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

compiler = 'pgi'
compiler_c = 'cc'
compiler_f = 'ftn'
compiler_mpi = True
compiler_opts = {
    'pgi': {
        'f': '-Mdclchk',
        'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
        't': '-Ktrap=fp -Mbounds',
        'p': '-pg -Mprof=func',
        'O': '-fast',
        '8': '-Mr8',
    },
    'gnu': {
        'f': '-fimplicit-none -Wall',
        'g': '-fbounds-check -ffpe-trap=invalid,zero,overflow -g',
        't': '-fbounds-check -ffpe-trap=invalid,zero,overflow',
        'p': '-O -pg',
        'O': '-O3',
        '8': '-fdefault-real-8',
    },
}

cvms_opts = {
    'compiler_opts': {
        'gnu': {
            'g': '-Wall -fbounds-check -ffpe-trap=invalid,zero,overflow -g',
            'O': '-Wall -O3',
        },
        'pgi': {
            'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
            'O': '-fast',
        },
    },
}

