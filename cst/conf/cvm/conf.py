#!/usr/bin/env python
"""
Default CVM configuration
"""
import os, pwd
import numpy as np

# command line options: (short, long, parameter, value)
options = [
    ( 'f', 'force',       'force',    True ),
    ( 'i', 'interactive', 'run',      'exec' ),
    ( 'b', 'batch',       'run',      'submit' ),
    ( 'q', 'queue',       'run',      'submit' ),
    ( 's', 'serial',      'mode',     's' ),
    ( 'm', 'mpi',         'mode',     'm' ),
]

# default options
force = False
run = False
mode = None
optimize = 'O'
nproc = 1
depend = False
seconds = 400
pre = post = ''
dtype = dtype_f = np.dtype( 'f' ).str
email = user = pwd.getpwuid( os.geteuid() )[0]
name = 'cvm4'
workdir = 'run'
reuse = True

# cvm input
nsample = None
lon_file = 'lon'
lat_file = 'lat'
dep_file = 'dep'
rho_file = 'rho'
vp_file = 'vp'
vs_file = 'vs'

# machine specific
notes = 'Default CVM configuration'
machine = ''
system = os.uname()
host = os.uname()[1]
hosts = host,
login = host
nproc = 1
maxnodes = 1
maxcores = 0
maxram = 0	
maxtime = 0
queue = None
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'mpiexec -np %(nproc)s %(command)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(command)s',
}

# search for file in PATH
def find( *files ):
    for d in os.environ['PATH'].split(':'):
        for f in files:
            if os.path.isfile( os.path.join( d, f ) ):
                return f

# Fortran compiler
fortran_serial = find( 'xlf95_r', 'ifort', 'pathf95', 'pgf95', 'pgf90', 'gfortran', 'f95' ),
fortran_mpi = find( 'mpxlf95_r', 'mpif90' ),

# Fortran compiler flags
fortran_flags_default_ = {
    'gfortran': {
        'g': ('-Wall', '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g'),
        'O': ('-Wall', '-O3'),
    },
    'ifort': {
        'g': ('-u', '-std95', '-warn', '-CB', '-traceback', '-g'),
        'O': ('-u', '-std95', '-warn', '-O3'),
    },
    'xlf95_r': {
        'g': ('-q64', '-qsuppress=cmpmsg', '-qfixed', '-C', '-qflttrap', '-qsigtrap', '-g'),
        'O': ('-q64', '-qsuppress=cmpmsg', '-qfixed', '-O4'),
    },
    'pgf90': {
        'g': ('-Ktrap=fp', '-Mbounds', '-g'),
        'O': ('-fast',),
    },
    'pgf95': {
        'g': ('-Ktrap=fp', '-Mbounds', '-g'),
        'O': ('-fast',),
    },
    'pathf95': {
        'g': ('-g',),
        'O': ('-i8', '-O3', '-OPT:Ofast', '-fno-math-errno'),
    },
}
if os.uname()[0] == 'SunOS':
    fortran_flags_default_.update( {
        'f95': {
            'g': ('-u', '-C', '-ftrap=common', '-w4', '-g'),
            'O': ('-u', '-O2', '-w1'), # anything higher than -O2 breaks it
        }
    } )

