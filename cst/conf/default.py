"""
Coseis Default Configuration
"""

import os, sys, pwd, socket
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
run = ''         # 'exec': interactive, 'submit': batch queue
rundir = 'run/{name}' # name of the run directory
new = True       # create new run directory
force = False    # overwrite previous run directory if present
stagein = []     # files to copy into run directory
optimize = 'O'   # 'O': optimize, 'g': debug, 'p': profile
depend = ''      # wait for other job to finish. supply job ID to depend.
nproc = 1        # number of processors
command = ''     # executable command
dtype = dtype_f = np.dtype('f').str # Numpy data type
verbose = False  # extra diagnostics
minutes = 0      # estimated run time
cvms_opts = {}   # dictionary of special option for the CVM-S code
openmp = False   # 
pre = post = ''

# machine specific
machine = ''
account = ''
host = socket.getfqdn()
host_opts = {}
system = os.uname()
queue = ''
queue_opts = []
core_range = []
node_range = []
maxnodes = 1
maxram = 0
pmem = 0
maxtime = 0
rate = 1.0e6
nstripe = -2

# command line options
argv = sys.argv[1:]
options = [
    ('v', 'verbose',     'verbose',  True),
    ('f', 'force',       'force',    True),
    ('n', 'dry-run',     'prepare',  False),
    ('i', 'interactive', 'run',      'exec'),
    ('q', 'queue',       'run',      'submit'),
    ('m', 'openmp',      'openmp',   True),
    ('g', 'debugging',   'optimize', 'g'),
    ('p', 'profiling',   'optimize', 'p'),
    ('O', 'optimized',   'optimize', 'O'),
    ('8', 'realsize8',   'dtype',    'f8'),
]

# search for files in PATH
def find(*files):
    import os
    path = os.environ['PATH'].split(':')
    for f in files:
        for p in path:
            if os.path.isfile(os.path.join(p, f)):
                return f

# default compiler
f2py_flags = ''
compiler = 'gnu'
compiler_cc = find('mpicc', 'gcc')
compiler_f90 = find('mpif90', 'gfortran')
compiler_mpi = 'mpi' in compiler_f90
compiler_openmp = False
compiler_opts = {
    'f': '-fimplicit-none -Wall',
    'g': '-fbounds-check -ffpe-trap=invalid,zero,overflow -g',
    'O': '-O3',
    'p': '-O3 -g -pg',
    'm': '-fopenmp',
    '8': '-fdefault-real-8',
}

# launch commands
if compiler_mpi:
    launch = {'exec': 'mpiexec -np {nproc} {command}'}
else:
    launch = {'exec': '{command}'}
launch_command = ''
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'

script = """\
#!/bin/sh
cd "{rundir}"
env >> {name}.env
echo "$( date ): {name} started" >> {name}.log
{pre}
{launch_command}
{post}
echo "$( date ): {name} finished" >> {name}.log
"""

del(os, sys, pwd, socket, np, find)

