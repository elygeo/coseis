#!/usr/bin/env python
"""
Default configuration parameters
"""
import os, pwd
import numpy as np

# Setup options (also accessible with command line options).
prepare = True    # True: compile code and setup run directory, False: dry run
optimize = 'O'    # O: fully optimized, g: debugging, t: testing, p: profiling
mode = None       # s: serial, m: MPI, None: guess from nproc3
run = False       # i: interactive, q: batch queue, g: debugger
pre = ''          # pre-processing command
post = ''         # post-processing command
itbuff = 10       # max number of timesteps to buffer for 2D & 3D output
rundir = 'run'    # run directory

# User info
user = pwd.getpwuid( os.geteuid() )[0]
try:
    email = open( 'email' ).read().strip()
except( IOError ):
    email = user

# Machine specific
machine = ''
notes = 'Default machine'
os_ = os.uname()
host = os.uname()[1]
hosts = host,
login = host
maxnodes = 1
maxcores = 0
maxram = 0	
maxtime = 0
rate = 1.0e6
queue = None
dtype = dtype_f = np.dtype( 'f' ).str

# Search for file in PATH
def find( *files ):
    for d in os.environ['PATH'].split(':'):
        for f in files:
            if os.path.isfile( os.path.join( d, f ) ):
                return f

# Fortran compiler
fortran_serial = find( 'xlf95_r', 'ifort', 'pathf95', 'pgf90', 'gfortran', 'f95' ),
fortran_mpi = find( 'mpxlf95_r', 'mpif90' ),

# Fortran compiler flags
fortran_flags_default = {
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
    fortran_flags_default.update( {
        'f95': {
            'f': ('-u'),
            'g': ('-C', '-ftrap=common', '-w4', '-g'),
            't': ('-C', '-ftrap=common'),
            'p': ('-O', '-pg'),
            'O': ('-fast', '-fns'),
            '8': ( 'FIXME', ),
        }
    } )

