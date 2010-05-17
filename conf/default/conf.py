#!/usr/bin/env python
"""
Default configuration
"""
import os, pwd
import numpy as np

rundir = 'run'
mode = 's'
run = False
pre = post = ''
email = user = pwd.getpwuid( os.geteuid() )[0]
nproc = 1

name = 'default'
machine = ''
system = os.uname()
host = os.uname()[1]
hosts = host,
login = host
maxnodes = 1
maxcores = 0
maxram = 0
maxtime = 0
dtype = np.dtype( 'f' ).str
depend = False
submit_pattern = r'(?P<jobid>\d+\S*)\D*$'
launch = {
    's_exec':  '%(bin)s',
    's_debug': 'gdb %(bin)s',
    'm_exec':  'mpiexec -np %(nproc)s %(bin)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(bin)s',
}

