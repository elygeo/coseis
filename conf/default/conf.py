notes = """
Default configuration
"""
import os, sys
login = os.uname()[1]
hosts = [ login ]
nodes = 1
cores = 0
ram = 0
rate = 500
timelimit = 0
sfc = None
mfc = None
for _dir in os.environ['PATH'].split(':'):
    for _f in [ 'xlf95_r', 'ifort', 'pgf90', 'gfortran', 'f95' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            sfc = _f
            break
    if sfc: break
for _dir in os.environ['PATH'].split(':'):
    for _f in [ 'mpxlf95_r', 'mpif90' ]:
        if os.path.isfile( _dir + os.sep + _f ):
            mfc = _f
            break
    if mfc: break
_ = [ '-o' ]
g = [ '-g' ]
p = [ '-O', '-p' ]
O = [ '-O' ]
getarg = ''
if sfc == 'gfortran':
    _ = [ '-fimplicit-none', '-Wall', '-o' ]
    g = [ '-g', '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ]
    p = [ '-O', '-pg' ]
    O = [ '-O3' ]
elif sfc == 'ifort':
    _ = [ '-u', '-std95', '-warn', '-o' ]
    g = [ '-g', '-CB', '-traceback' ]
    O = [ '-O3' ]
elif sfc == 'pgf90':
    getarg = 'getarg-pgf.f90'
    g = [ '-g', '-Ktrap=fp', '-Mbounds', '-Mdclchk' ]
    p = [ '-O', '-Mprof=func' ]
    O = [ '-fast' ]
elif sfc == 'xlf95_r':
    _ = [ '-u', '-q64', '-qsuppress=cmpmsg', '-qlanglvl=2003pure', '-qsuffix=f=f90', '-o' ]
    g = [ '-g', '-C', '-qflttrap', '-qsigtrap' ]
    O = [ '-O4' ]
elif sfc == 'f95' and os.uname()[0] == 'SunOS':
    getarg = 'getarg.f90'
    g = [ '-w4', '-C', '-g', '-u' ]
    O = [ '-w1', '-fast', '-u' ]
if sfc: sfc = [ sfc ]
if mfc: mfc = [ mfc ]
g = g + _
O = O + _
p = p + _

