#!/usr/bin/env python
"""
Default configuration
"""
import os, pwd
import numpy as np

rundir = 'run'
mode = 's'
pre = post = ''
email = user = pwd.getpwuid( os.geteuid() )[0]
nproc = 1

name = 'default'
machine = ''
system = os.uname()
host = os.uname()[1]
hosts = host,
login = host
batch = None
maxnodes = 1
maxcores = 0
maxram = 0
maxtime = 0
dtype = np.dtype( 'f' ).str

