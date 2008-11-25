#!/usr/bin/env python
"""
Default configuration parameters
"""

import os, sys, pwd

# Setup options (also accessible with command line options).
prepare = True	# True: compile code and setup run directory, False: dry run
optimize = 'O'	# O: fully optimized, g: debugging, t: testing, p: profiling
mode = None	# s: serial, m: MPI, None: guess from np3 
run = False	# i: interactive, q: batch queue, g: debugger
rundir = 'run'	# run directory
name = 'sord'	# name of current simulation
pre = ''	# pre-processing command
post = ''	# post-processing command
itbuff = 10	# max number of timesteps to buffer for 2D & 3D output

# User info
user = pwd.getpwuid(os.geteuid())[0]
try: email = open( 'email', 'r' ).read().strip()
except: email = user

# Machine specific
machine = ''
notes = "Default machine"
os_ = os.uname()
host = os.uname()[1]
hosts = [ host ]
login = host
maxnodes = 1
maxcores = 0
maxram = 0	
maxtime = 0
rate = 1.0e6
queue = None
endian = sys.byteorder[0]
floatsize = 4

# Serial Fortran compiler
fortran_serial = None
for _dir in os.environ['PATH'].split(':'):
    if fortran_serial: break
    for _f in [ 'xlf95_r', 'ifort', 'pathf95', 'pgf90', 'gfortran', 'f95' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            fortran_serial = [ _f ]
            break

# MPI Fortran compiler
fortran_mpi = None
for _dir in os.environ['PATH'].split(':'):
    if fortran_mpi: break
    for _f in [ 'mpxlf95_r', 'mpif90' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            fortran_mpi = [ _f ]
            break

# Fortran compiler flags
if fortran_serial[0] == 'xlf95_r':
    _ = [ '-u', '-q64', '-qsuppress=cmpmsg', '-qlanglvl=2003pure', '-qsuffix=f=f90', '-o' ]
    fortran_flags = {
        'g': [ '-C', '-qflttrap', '-qsigtrap', '-g' ] + _,
        't': [ '-C', '-qflttrap', '-qsigtrap' ] + _,
        'p': [ '-O', '-p' ] + _,
        'O': [ '-O4' ] + _,
    }
elif fortran_serial[0] == 'ifort':
    _ = [ '-u', '-std95', '-warn', '-o' ]
    fortran_flags = {
        'g': [ '-CB', '-traceback', '-g' ] + _,
        't': [ '-CB', '-traceback' ] + _,
        'p': [ '-O', '-pg' ] + _,
        'O': [ '-O3' ] + _,
    }
elif fortran_serial[0] == 'pgf90':
    _ = [ '-Mdclchk', '-o' ]
    fortran_flags = {
        'g': [ '-Ktrap=fp', '-Mbounds', '-g' ] + _,
        't': [ '-Ktrap=fp', '-Mbounds' ] + _,
        'p': [ '-O', '-Mprof=func' ] + _,
        'O': [ '-fast' ] + _,
    }
elif fortran_serial[0] == 'pathf95':
    _ = [ '-o' ]
    fortran_flags = {
        'g': [ '-g' ] + _,
        't': [] + _,
        'p': [ '-O', '-p' ] + _,
        'O': [ '-i8', '-O3', '-OPT:Ofast', '-fno-math-errno' ] + _,
    }
elif fortran_serial[0] == 'gfortran':
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-pedantic', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-o' ]
    fortran_flags = {
        'g': [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g' ] + _,
        't': [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _,
        'p': [ '-O', '-pg' ] + _,
        'O': [ '-O3' ] + _,
    }
elif fortran_serial[0] == 'f95' and os.uname()[0] == 'SunOS':
    _ = [ '-u', '-o' ]
    fortran_flags = {
        'g': [ '-C', '-ftrap=common', '-w4', '-g' ] + _,
        't': [ '-C', '-ftrap=common'  ] + _,
        'p': [ '-O', '-pg' ] + _,
        'O': [ '-fast', '-fns' ] + _,
    }

