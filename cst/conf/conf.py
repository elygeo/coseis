"""
Coseis configuration
"""
import os, pwd
import numpy as np

# email address
try:
    import configobj
    f = os.path.join( os.path.expanduser( '~' ), '.gitconfig' )
    email = configobj.ConfigObj( f )['user']['email']
except:
    email = pwd.getpwuid( os.geteuid() )[0]

# site specific
machine = None
repo = '~/coseis/data'

# job parameters
name = 'cst'
run = False      # 'exec': interactive, 'debug': debugger, 'submit': batch queue
rundir = 'run'
stagein = []     # files to copy into rundir
force = False    # overwrite previous run directory if present
prepare = True   # True: compile code and setup run directory, False: dry run
optimize = 'O'   # 'O': optimize, 'g': debug, 't': test, 'p': profile
mode = None      # 's': serial, 'm': MPI, None: guess
depend = False   # wait for other job to finish. supply job ID to depend.
nproc = 1
pre = post = ''  # pre-processing and post-processing commands
dtype = dtype_f = np.dtype( 'f' ).str # Numpy data type
verbose = False

# machine specific
host = hostname = os.uname()[1]
system = os.uname()
maxnodes = 1
maxcores = 0
maxram = 0
maxtime = 0
rate = 1.0e6
queue = None
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'mpiexec -np %(nproc)s %(command)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(command)s',
}

# command line options
argv = []
options = [
    ( '',  'machine=',    'machine',  '' ),
    ( 'v', 'verbose',     'verbose',  True ),
    ( 'f', 'force',       'force',    True ),
    ( 'n', 'dry-run',     'prepare',  False ),
    ( 'i', 'interactive', 'run',      'exec' ),
    ( 'd', 'debug',       'run',      'debug' ),
    ( 'b', 'batch',       'run',      'submit' ),
    ( 'q', 'queue',       'run',      'submit' ),
    ( 's', 'serial',      'mode',     's' ),
    ( 'm', 'mpi',         'mode',     'm' ),
    ( 'g', 'debugging',   'optimize', 'g' ),
    ( 't', 'testing',     'optimize', 't' ),
    ( 'p', 'profiling',   'optimize', 'p' ),
    ( 'O', 'optimized',   'optimize', 'O' ),
    ( '8', 'realsize8',   'dtype',    'f8' ),
]

# search for file in PATH
def find( *files ):
    for d in os.environ['PATH'].split(':'):
        for f in files:
            if os.path.isfile( os.path.join( d, f ) ):
                return f

# Fortran compiler
fortran_serial = find( 'xlf95_r', 'ifort', 'gfortran', 'pathf95', 'pgf90', 'f95' )
fortran_mpi = find( 'mpxlf95_r', 'mpif90' )
f2py_flags = ''

# Fortran compiler flags
fortran_flags_default_ = {
    'gfortran': {
        #'f': 'gfortran -fimplicit-none -Wall -std=f95 -pedantic',
        'f': '-fimplicit-none -Wall',
        'g': '-fbounds-check -ffpe-trap=invalid,zero,overflow -g',
        't': '-fbounds-check -ffpe-trap=invalid,zero,overflow',
        'p': '-O -pg',
        'O': '-O3',
        '8': '-fdefault-real-8',
    },
    'ifort': {
        'f': '-u -std95 -warn',
        'g': '-CB -traceback -g',
        't': '-CB -traceback',
        'p': '-O -pg',
        'O': '-O3',
        '8': '-r8',
    },
    'pgf90': {
        'f': '-Mdclchk',
        'g': '-Ktrap=fp -Mbounds -g',
        't': '-Ktrap=fp -Mbounds',
        'p': '-O -Mprof=func',
        'O': '-fast',
        '8': '-Mr8',
    },
    'xlf95_r': {
        'f': '-u -q64 -qsuppress=cmpmsg -qlanglvl=2003pure -qsuffix=f=f90',
        'g': '-C -qflttrap -qsigtrap -g',
        't': '-C -qflttrap -qsigtrap',
        'p': '-O -p',
        'O': '-O4',
        '8': '-qrealsize=8',
    },
    'pathf95': {
        'f': '',
        'g': '-g',
        't': '',
        'p': '-O -p',
        'O': '-i8 -O3 -OPT:Ofast -fno-math-errno',
        '8':  'FIXME',
    }
}
if os.uname()[0] == 'SunOS':
    fortran_flags_default_.update( {
        'f95': {
            'f': '-u',
            'g': '-C -ftrap=common -w4 -g',
            't': '-C -ftrap=common',
            'p': '-O -pg',
            'O': '-fast -fns',
            '8':  'FIXME',
        }
    } )

