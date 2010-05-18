#!/usr/bin/env python
"""
Default configuration
"""
import os, pwd
import numpy as np

# command line options
options = [
    ( 'i', 'interactive', 'run',      'exec' ),
    ( 'b', 'batch',       'run',      'submit' ),
    ( 'q', 'queue',       'run',      'submit' ),
    ( 's', 'serial',      'mode',     's' ),
    ( 'm', 'mpi',         'mode',     'm' ),
]

# default options
run = False
mode = 's'
name = 'job'
rundir = 'run'
depend = False
nproc = 1
pre = post = ''
dtype = np.dtype( 'f' ).str
email = user = pwd.getpwuid( os.geteuid() )[0]

# machine specific
machine = ''
system = os.uname()
host = os.uname()[1]
hosts = host,
login = host
maxnodes = 1
maxcores = 0
maxram = 0
maxtime = 0
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'
launch = {
    's_exec':  '%(bin)s',
    's_debug': 'gdb %(bin)s',
    'm_exec':  'mpiexec -np %(nproc)s %(bin)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(bin)s',
}

