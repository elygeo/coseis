"""
TACC Ranger: Sun Constellation Linux Cluster

ssh ranger.tacc.utexas.edu
EPD version: rh3-x86_64
mvapich2 supports MPI2, but not recommended for more than 2048 tasks.

.profile_user:
module load git
module swap pgi intel

.bashrc:
alias qme='showq -u'
alias qdev='idev -minutes 120'

gsiftp://gridftp.ranger.tacc.teragrid.org:2811/
http://www.tacc.utexas.edu/services/userguides/ranger/
ppn must be one of (1, 2, 4, 8, 12, 15, 16)

cat /share/sge/default/tacc/sge_esub_control
qconf -sql
lfs quota -u $USER $HOME
lfs quota -u $USER $WORK
lfs quota -u $USER $SCRATCH

# needed?
module load gotoblas scalapack mkl
export F77=ifort
export F90=ifort
export F77=pgf95
export F90=pgf95
"""

maxcores = 16
maxram = 32 * 1024
#rate = 21e5
rate = 12e5

queue_opts = [
    ('development', {'maxnodes': 16,   'maxtime':  2 * 60}),
    ('normal',      {'maxnodes': 256,  'maxtime': 24 * 60}),
    ('large',       {'maxnodes': 1024, 'maxtime': 24 * 60}),
    ('long',        {'maxnodes': 256,  'maxtime': 48 * 60}),
    ('serial',      {'maxnodes': 1,    'maxtime':  2 * 60}),
    ('vis',         {'maxnodes': 2,    'maxtime': 24 * 60}),
    ('request', {}),
]

f2py_flags = '--fcompiler=intelem'
compiler = 'pgi'
compiler_c = 'mpicc'
compiler_f = 'mpif90'
compiler_opts = {
    'pgi': {
        'f': '-Mdclchk',
        'g': '-Ktrap=fp -Mbounds -g',
        't': '-Ktrap=fp -Mbounds',
        'p': '-fast -tp barcelona-64 -Mprof=func',
        'O': '-fast -tp barcelona-64',
        '8': '-Mr8',
    },
     'intel': {
        'f': '-u -std03 -warn',
        'g': '-CB -traceback -g',
        't': '-CB -traceback',
        'p': '-O -pg',
        'O': '-O2 -xW',
        '8': '-r8',
    },
    'sun': {
        'f': '-u',
        'g': '-C -ftrap=common -w4 -g',
        't': '-C -ftrap=common',
        'p': '-O -pg',
        'O': '-fast -fns',
    },  
}

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'ibrun {command}',
    'm_iexec': 'ibrun -n {nproc} -o 0 {command}',
    'm_debug': 'ddt -start -once -n {nproc} -- {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -hold_jid "{depend}" "{name}.sh"',
}

