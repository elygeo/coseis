"""
Coseis Default Configuration
"""

import os, sys, pwd
import numpy as np

# email address
try:
    import configobj
    f = os.path.join(os.path.expanduser('~'), '.gitconfig')
    email = configobj.ConfigObj(f)['user']['email']
    del(configobj, f)
except:
    email = pwd.getpwuid(os.geteuid())[0]

# job parameters
name = 'cst'     # configuration name
prepare = True   # True: compile code and setup run directory, False: dry run
run = ''         # 'exec': interactive, 'debug': debugger, 'submit': batch queue
rundir = 'run/{name}' # name of the run directory
new = True       # create new run directory
force = False    # overwrite previous run directory if present
stagein = []     # files to copy into run directory
optimize = 'O'   # 'O': optimize, 'g': debug, 't': test, 'p': profile
mode = ''        # 's': serial, 'm': MPI, '': guess
depend = ''      # wait for other job to finish. supply job ID to depend.
nproc = 1        # number of processors
command = ''     # executable command
dtype = dtype_f = np.dtype('f').str # Numpy data type
verbose = False  # extra diagnostics
minutes = 60     # estimated run time
cvms_opts = {}   # dictionary of special option for the CVM-S code
pre = post = ''

# machine specific
machine = ''
account = ''
login = host = hostname = os.uname()[1]
system = os.uname()
queue = ''
queue_opts = []
maxnodes = 1
maxcores = 0
maxram = 0
pmem = 0
maxtime = 0
rate = 1.0e6
nstripe = -2
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'
launch_command = ''
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpiexec -np {nproc} {command}',
    'm_debug': 'mpiexec -np {nproc} -gdb {command}',
}

script = """\
#!/bin/sh
cd "{rundir}"
env > {name}-env
echo "$( date ): {name} started" >> {name}-log
{pre}
{launch_command}
{post}
echo "$( date ): {name} finished" >> {name}-log
"""

# command line options
argv = sys.argv[1:]
options = [
    ('v', 'verbose',     'verbose',  True),
    ('f', 'force',       'force',    True),
    ('n', 'dry-run',     'prepare',  False),
    ('i', 'interactive', 'run',      'exec'),
    ('d', 'debug',       'run',      'debug'),
    ('b', 'batch',       'run',      'submit'),
    ('q', 'queue',       'run',      'submit'),
    ('s', 'serial',      'mode',     's'),
    ('m', 'mpi',         'mode',     'm'),
    ('g', 'debugging',   'optimize', 'g'),
    ('t', 'testing',     'optimize', 't'),
    ('p', 'profiling',   'optimize', 'p'),
    ('O', 'optimized',   'optimize', 'O'),
    ('8', 'realsize8',   'dtype',    'f8'),
]

# search for file in PATH
def find(*files):
    import os
    for d in os.environ['PATH'].split(':'):
        for f in files:
            if os.path.isfile(os.path.join(d, f)):
                return f

# compilers
c_serial = find('mpixlc_r', 'gcc')
c_mpi = find('mpixlc_r', 'mpicc')
fortran_serial = find('mpixlf2003_r', 'ifort', 'gfortran', 'pathf95', 'pgf90', 'f95')
fortran_mpi = find('mpixlf2003_r', 'mpif90')
f2py_flags = ''

del(os, sys, pwd, np, find)

# compiler flags
c_flags = {
    'mpixlc_r' : {
        'f': '',
        'g': '-g',
        'p': '-O3 -p',
        'O': '-O3',
    },
    'gcc' : {
        'f': '-Wall',
        'g': '-g',
        'p': '-O3 -pg',
        'O': '-O3',
    },
}
fortran_flags = {
    'gfortran': {
        #'f': '-fimplicit-none -Wall -std=f95 -pedantic',
        'f': '-fimplicit-none -Wall',
        'g': '-fbounds-check -ffpe-trap=invalid,zero,overflow -g',
        't': '-fbounds-check -ffpe-trap=invalid,zero,overflow',
        'p': '-O -pg',
        #'O': '-O3 -fopenmp',
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
    'mpixlf2003_r': {
        'f': '-qlanglvl=2003pure',
        'g': '-C -u -O0 -g',
        't': '-C',
        'p': '-O3',
        'O': '-O3 -qarch=450d -qtune=450',
        '8': '-qrealsize=8',
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
    },
    'f95': {
        'f': '-u',
        'g': '-C -ftrap=common -w4 -g',
        't': '-C -ftrap=common',
        'p': '-O -pg',
        'O': '-fast -fns',
        '8':  'FIXME',
    },
}

