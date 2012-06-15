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
host = socket.getfqdn()
host_opts = {}
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
    ('g', 'debugging',   'optimize', 'g'),
    ('t', 'testing',     'optimize', 't'),
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
compiler_c = find('mpicc', 'gcc')
compiler_f = find('mpif90', 'gfortran')
compiler_mpi = 'mpi' in compiler_f
compiler_opts = {
    'f': '-fimplicit-none -Wall',
    'g': '-fbounds-check -ffpe-trap=invalid,zero,overflow -g',
    't': '-fbounds-check -ffpe-trap=invalid,zero,overflow',
    'p': '-O -pg',
    'O': '-O3',
    '8': '-fdefault-real-8',
}

del(os, sys, pwd, socket, np, find)

