#!/usr/bin/env python
"""
Default SORD configuration
"""
import os, pwd
import numpy as np

# command line options: (short, long, parameter, value)
options = [
    ( 'n', 'dry-run',     'prepare',  False ),
    ( 'f', 'force',       'force',    True ),
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

# default options
prepare = True   # True: compile code and setup run directory, False: dry run
force = False    # overwrite previous run directory if present
run = False      # 'exec': interactive, 'debug': debugger, 'submit': batch queue
mode = None      # 'm': serial, 'm': MPI, None: guess
optimize = 'O'   # 'O': optimize, 'g': debug, 't': test, 'p': profile
dtype = dtype_f = np.dtype( 'f' ).str # Numpy data type

# other options
name = 'sord'    # job name
rundir = 'run'   # run directory
nproc = 1        # number of processes
depend = False   # wait for other job to finish. supply job ID to depend.
pre = post = ''  # pre-processing and post-processing commands
itbuff = 10      # max number of timesteps to buffer for 2D & 3D output
email = user = pwd.getpwuid( os.geteuid() )[0] # email address

# machine specific
notes = 'Default SORD configuration'
machine = ''
system = os.uname()
host = os.uname()[1]
hosts = host,
login = host
maxnodes = 1
maxcores = 0
maxram = 0	
maxtime = 0
rate = 1.0e6
queue = None
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'
launch = {
    's_exec':  '%(bin)s',
    's_debug': 'gdb %(bin)s',
    'm_exec':  'mpiexec -np %(nproc)s %(bin)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(bin)s',
}

# search for file in PATH
def find( *files ):
    for d in os.environ['PATH'].split(':'):
        for f in files:
            if os.path.isfile( os.path.join( d, f ) ):
                return f

# Fortran compiler
fortran_serial = find( 'xlf95_r', 'ifort', 'gfortran', 'pathf95', 'pgf90', 'f95' ),
fortran_mpi = find( 'mpxlf95_r', 'mpif90' ),

# Fortran compiler flags
fortran_flags_default_ = {
    'gfortran': {
        #'f': ('gfortran', '-fimplicit-none', '-Wall', '-std=f95', '-pedantic'),
        'f': ('-fimplicit-none', '-Wall'),
        'g': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g'),
        't': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow'),
        'p': ('-O', '-pg'),
        'O': ('-O3',),
        '8': ('-fdefault-real-8',),
    },
    'ifort': {
        'f': ('-u', '-std95', '-warn'),
        'g': ('-CB', '-traceback', '-g'),
        't': ('-CB', '-traceback'),
        'p': ('-O', '-pg'),
        'O': ('-O3',),
        '8': ('-r8',),
    },
    'pgf90': {
        'f': ('-Mdclchk',),
        'g': ('-Ktrap=fp', '-Mbounds', '-g'),
        't': ('-Ktrap=fp', '-Mbounds'),
        'p': ('-O', '-Mprof=func'),
        'O': ('-fast',),
        '8': ('-Mr8',),
    },
    'xlf95_r': {
        'f': ('-u', '-q64', '-qsuppress=cmpmsg', '-qlanglvl=2003pure', '-qsuffix=f=f90'),
        'g': ('-C', '-qflttrap', '-qsigtrap', '-g'),
        't': ('-C', '-qflttrap', '-qsigtrap'),
        'p': ('-O', '-p'),
        'O': ('-O4',),
        '8': ('-qrealsize=8',),
    },
    'pathf95': {
        'f': (),
        'g': ('-g',),
        't': (),
        'p': ('-O', '-p'),
        'O': ('-i8', '-O3', '-OPT:Ofast', '-fno-math-errno'),
        '8': ( 'FIXME', ),
    }
}
if os.uname()[0] == 'SunOS':
    fortran_flags_default_.update( {
        'f95': {
            'f': ('-u'),
            'g': ('-C', '-ftrap=common', '-w4', '-g'),
            't': ('-C', '-ftrap=common'),
            'p': ('-O', '-pg'),
            'O': ('-fast', '-fns'),
            '8': ( 'FIXME', ),
        }
    } )

