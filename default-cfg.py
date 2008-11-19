#!/usr/bin/env python
notes = """
Default configuration
"""

import os, sys

# Setup options. These are also accessible with command line flags.
prepare = True		# True: compile code and setup run/ directory, False: dry run
run = False		# i: interactive, q: batch queue, g: debugger
mode = None		# None: guess, s: serial, m: MPI
optimize = 'O'		# O: fully optimized, g: debugging, t: testing, p: profiling
itbuff = 10		# max number of timesteps to buffer for 2D & 3D output

# Machine specific configuration
machine = None		# optional name of custome machine configuration
login = os.uname()[1]	# login address
hosts = [ login ]	# possible hostnames
nodes = 1		#
cores = 0		#
ram = 0			# 
rate = 1.0e6		#
timelimit = 0		#
queue = None		# batch queue name

# Detect Fortran compiler
sfc = None		# serial fortran compiler
mfc = None		# MPI fortran compiler
for _dir in os.environ['PATH'].split(':'):
    if sfc: break
    for _f in [ 'xlf95_r', 'ifort', 'pathf95', 'pgf90', 'gfortran', 'f95' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            sfc = [ _f ]
            break

for _dir in os.environ['PATH'].split(':'):
    if mfc: break
    for _f in [ 'mpxlf95_r', 'mpif90' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            mfc = [ _f ]
            break

if sfc[0] == 'xlf95_r':
    getarg = ''
    _ = [ '-u', '-q64', '-qsuppress=cmpmsg', '-qlanglvl=2003pure', '-qsuffix=f=f90', '-o' ]
    g = [ '-C', '-qflttrap', '-qsigtrap', '-g' ] + _
    t = [ '-C', '-qflttrap', '-qsigtrap' ] + _
    p = [ '-O', '-p' ] + _
    O = [ '-O4' ] + _
elif sfc[0] == 'ifort':
    getarg = ''
    _ = [ '-u', '-std95', '-warn', '-o' ]
    g = [ '-CB', '-traceback', '-g' ] + _
    t = [ '-CB', '-traceback' ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-O3' ] + _
elif sfc[0] == 'pgf90':
    getarg = 'getarg-pgf.f90'
    _ = [ '-Mdclchk', '-o' ]
    g = [ '-Ktrap=fp', '-Mbounds', '-g' ] + _
    t = [ '-Ktrap=fp', '-Mbounds' ] + _
    p = [ '-O', '-Mprof=func' ] + _
    O = [ '-fast' ] + _
elif sfc[0] == 'pathf95':
    getarg = ''
    _ = [ '-o' ]
    g = [ '-g' ] + _
    t = [] + _
    p = [ '-O', '-p' ] + _
    O = [ '-i8', '-O3', '-OPT:Ofast', '-fno-math-errno' ] + _
elif sfc[0] == 'gfortran':
    getarg = ''
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-pedantic', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-o' ]
    g = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g' ] + _
    t = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-O3' ] + _
elif sfc[0] == 'f95' and os.uname()[0] == 'SunOS':
    getarg = 'getarg.f90'
    _ = [ '-u', '-o' ]
    g = [ '-C', '-ftrap=common', '-w4', '-g' ] + _
    t = [ '-C', '-ftrap=common'  ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-fast', '-fns' ] + _

