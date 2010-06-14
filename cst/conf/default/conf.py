#!/usr/bin/env python
"""
Default configuration
"""
import os, pwd
import numpy as np

# options
options = [
    ( '', 'machine=', 'machine', str ),
]

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
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'mpiexec -np %(nproc)s %(command)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(command)s',
}

