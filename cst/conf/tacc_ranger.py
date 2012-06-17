"""
TACC Ranger: Sun Constellation

ranger.tacc.utexas.edu

.bashrc:
export PATH=/share/home/00967/gely/local/python/bin:${PATH}
export PATH=${HOME}/coseis/bin:${PATH}
export PYTHONPATH=${HOME}/coseis

.profile_user:
module unload mvapich pgi
module load intel mvapich
module load git
"""

core_range = [1, 2, 4, 8, 12, 15, 16]
maxram = 32768
rate = 12e5

queue_opts = [
    ('development', {'maxnodes': 16,   'maxtime':  120}),
    ('normal',      {'maxnodes': 256,  'maxtime': 1440}),
    ('large',       {'maxnodes': 1024, 'maxtime': 1440}),
    ('long',        {'maxnodes': 256,  'maxtime': 2880}),
    ('serial',      {'maxnodes': 1,    'maxtime':  120}),
    ('vis',         {'maxnodes': 2,    'maxtime': 1440}),
    ('request', {}),
]

f2py_flags = '--fcompiler=intelem'
compiler_cc = 'mpicc'
compiler_f90 = 'mpif90'
compiler_opts = {
    'pgi': {
        'f': '-Mdclchk',
        'g': '-Ktrap=fp -Mbounds -g',
        'O': '-fast -tp barcelona-64',
        'p': '-fast -tp barcelona-64 -g -Mprof=func',
        '8': '-Mr8',
    },
     'intel': {
        'f': '-u -std03 -warn',
        'g': '-CB -traceback -g',
        'O': '-O2 -xW',
        'p': '-O2 -xW -g -pg',
        '8': '-r8',
    },
    'sun': {
        'f': '-u',
        'g': '-C -ftrap=common -w4 -g',
        'O': '-fast -fns',
        'p': '-fast -fns -g -pg',
    },
}

launch = {
    'exec': 'ibrun {command}',
    'iexec': 'ibrun -n {nproc} -o 0 {command}',
    'submit': 'qsub "{name}.sh"',
    'submit2': 'qsub -hold_jid "{depend}" "{name}.sh"',
}

