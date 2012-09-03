"""
Coseis Configuration
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
code = 'cst'              # code name
name = 'cst'              # job name
verbose = False           # extra diagnostics
prepare = True            # True: setup run directory, False: dry run
run = ''                  # 'exec': interactive, 'submit': batch queue
rundir = 'run/{name}'     # name of the run directory
new = True                # create new run directory
force = False             # overwrite previous run directory
stagein = []              # files to copy into run directory
dtype = np.dtype('f').str # Numpy data type
nproc = 1                 # number of processes
nthread = 0               # number of threads per process
command = ''              # executable command
pre = post = ''           # pre and post-processing commands
depend = ''               # job ID to wait for
minutes = 0               # estimated run time

# machine specific
machine = ''
account = ''
host = os.uname()
host = '-'.join((host[0], host[4], host[1], socket.getfqdn()))
host_opts = {}
system = os.uname()
queue = ''
queue_opts = []
ppn_range = []
maxnodes = 1
maxcores = 1
maxram = 0
pmem = 0
maxtime = 0
rate = 1.0e6
nstripe = -2

# command line options
argv = sys.argv[1:]
options = [
    ('v', 'verbose',     'verbose', True),
    ('f', 'force',       'force',   True),
    ('n', 'dry-run',     'prepare', False),
    ('s', 'setup',       'run',     ''),
    ('i', 'interactive', 'run',     'exec'),
    ('q', 'queue',       'run',     'submit'),
]

# search for files in PATH
def find(*files):
    import os
    path = os.environ['PATH'].split(':')
    for f in files:
        for p in path:
            if os.path.isfile(os.path.join(p, f)):
                return f

# default compiler: GNU
f2py_flags = ''
build_cc = find('mpicc', 'gcc')
build_fc = find('mpif90', 'gfortran')
build_ld = build_fc
build_mpi = 'mpi' in build_cc
build_libs = ''
build_ldflags = '-g -O3 -Wall -fopenmp -fbounds-check -ffpe-trap=invalid,zero,overflow'
build_ldflags = '-g -O3 -Wall -fopenmp -pg'
build_ldflags = '-g -O3 -Wall -fopenmp'
build_cflags = build_ldflags
build_fflags = build_ldflags + ' -fimplicit-none -fdefault-real-8'
build_fflags = build_ldflags + ' -fimplicit-none'

# default scheduler: PBS
if build_mpi:
    launch = 'mpiexec -np {nproc} {command}'
else:
    launch = '{command}'
notify_threshold = 4096
notify = '-m abe'
submit_flags = ''
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'
submit = 'qsub {notify} {submit_flags} "{code}.sh"'
submit2 = 'qsub {notify} -W depend="afterok:{depend}" {submit_flags} "{code}.sh"'

# batch script
script = """\
#!/bin/sh
cd "{rundir}"
env >> {code}.env
echo "$( date ): {code} started" >> {code}.log
{pre}
{launch}
{post}
echo "$( date ): {code} finished" >> {code}.log
"""

# detect machine from the hostname
for m, h in [
    ('alcf_bgq', 'vestalac1.ftd.alcf.anl.gov'),
    ('alcf_bgp', 'surveyor.alcf.anl.gov'),
    ('alcf_bgp', 'challenger.alcf.anl.gov'),
    ('alcf_bgp', 'intreplid.alcf.anl.gov'),
    ('wat2q',   'grotius.watson.ibm.com'),
    ('usc_hpc', 'hpc-login1.usc.edu'),
    ('usc_hpc', 'hpc-login2-l.usc.edu'),
    ('tacc_ranger', 'ranger.tacc.utexas.edu'),
    ('nics_kraken', 'kraken'),
    ('airy', 'airy'),
]:
    if h in host:
        machine = m
        break

# clean up the namespace
del(m, h)
del(os, sys, pwd, socket, np, find)

