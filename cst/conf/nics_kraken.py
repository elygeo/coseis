"""
NICS Kraken: Cray XT5

gsissh kraken-pwd.nics.utk.edu /lustre/scratch/

.bashrc
module swap PrgEnv-pgi PrgEnv-gnu
module load git vim yt
alias qme='qstat -u $USER'
alias qdev='qsub -I -A account_string -l size=12,walltime=2:00:00'

useful:
showq
showbf
showusage
CrayPAT: profiling & hardware performance

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
"""

maxram = 16384
core_range = [12]
maxnodes = 64 * 129
maxtime = 1440
rate = 1e6

launch = {
    'exec': 'aprun -n {nproc} {command}',
    'debug': 'totalview aprun -n {nproc} {command}',
    'submit': 'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

compiler_c = 'cc'
compiler_f = 'ftn'
compiler_mpi = True
compiler_opts = {
    'pgi': {
        'f': '-Mdclchk',
        't': '-Ktrap=fp -Mbounds',
        'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
        'O': '-fast',
        'p': '-fast -pg -Mprof=func',
        '8': '-Mr8',
    },
    'gnu': {
        'f': '-fimplicit-none -Wall',
        't': '-fbounds-check -ffpe-trap=invalid,zero,overflow',
        'g': '-fbounds-check -ffpe-trap=invalid,zero,overflow -g',
        'O': '-O3',
        'p': '-O3 -pg',
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

