#!/usr/bin/env python
"""
Default configuration parameters
"""

import os, sys, pwd

# Setup options (also accessible with command line options).
prepare = True	# True: compile code and setup run/ directory, False: dry run
run = False	# i: interactive, q: batch queue, g: debugger
mode = None	# None: guess, s: serial, m: MPI
optimize = 'O'	# O: fully optimized, g: debugging, t: testing, p: profiling
itbuff = 10	# max number of timesteps to buffer for 2D & 3D output

# User
user = pwd.getpwuid(os.geteuid())[0]
try: email = file( 'email', 'r' ).read().strip()
except: email = user

# Machine specific
notes = "Default machine"
machine = ''
os_ = os.uname()[3]
login = os.uname()[1]
host = login
hosts = [ login ]
maxnodes = 1
maxcores = 0
maxram = 0	
maxtime = 0
rate = 1.0e6
queue = None

# Serial Fortran compiler
sfc = None
for _dir in os.environ['PATH'].split(':'):
    if sfc: break
    for _f in [ 'xlf95_r', 'ifort', 'pathf95', 'pgf90', 'gfortran', 'f95' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            sfc = [ _f ]
            break

# MPI Fortran compiler
mfc = None
for _dir in os.environ['PATH'].split(':'):
    if mfc: break
    for _f in [ 'mpxlf95_r', 'mpif90' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            mfc = [ _f ]
            break

# Fortran compiler flags
if sfc[0] == 'xlf95_r':
    _ = [ '-u', '-q64', '-qsuppress=cmpmsg', '-qlanglvl=2003pure', '-qsuffix=f=f90', '-o' ]
    g = [ '-C', '-qflttrap', '-qsigtrap', '-g' ] + _
    t = [ '-C', '-qflttrap', '-qsigtrap' ] + _
    p = [ '-O', '-p' ] + _
    O = [ '-O4' ] + _
    getarg = ''
elif sfc[0] == 'ifort':
    _ = [ '-u', '-std95', '-warn', '-o' ]
    g = [ '-CB', '-traceback', '-g' ] + _
    t = [ '-CB', '-traceback' ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-O3' ] + _
    getarg = ''
elif sfc[0] == 'pgf90':
    _ = [ '-Mdclchk', '-o' ]
    g = [ '-Ktrap=fp', '-Mbounds', '-g' ] + _
    t = [ '-Ktrap=fp', '-Mbounds' ] + _
    p = [ '-O', '-Mprof=func' ] + _
    O = [ '-fast' ] + _
    getarg = 'getarg-pgf.f90'
elif sfc[0] == 'pathf95':
    _ = [ '-o' ]
    g = [ '-g' ] + _
    t = [] + _
    p = [ '-O', '-p' ] + _
    O = [ '-i8', '-O3', '-OPT:Ofast', '-fno-math-errno' ] + _
    getarg = ''
elif sfc[0] == 'gfortran':
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-pedantic', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-o' ]
    g = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g' ] + _
    t = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-O3' ] + _
    getarg = ''
elif sfc[0] == 'f95' and os.uname()[0] == 'SunOS':
    _ = [ '-u', '-o' ]
    g = [ '-C', '-ftrap=common', '-w4', '-g' ] + _
    t = [ '-C', '-ftrap=common'  ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-fast', '-fns' ] + _
    getarg = 'getarg.f90'

