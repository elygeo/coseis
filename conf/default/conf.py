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
    for _f in [ 'xlf95_r', 'ifort', 'pathf95', 'pgf90', 'gfortran', 'f95' ]:
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

if sfc == 'gfortran':
    getarg = ''
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-pedantic', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-std=f95', '-o' ]
    _ = [ '-fimplicit-none', '-Wall', '-o' ]
    g = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g' ] + _
    t = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-O3' ] + _
elif sfc == 'ifort':
    getarg = ''
    _ = [ '-u', '-std95', '-warn', '-o' ]
    g = [ '-CB', '-traceback', '-g' ] + _
    t = [ '-CB', '-traceback' ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-O3' ] + _
elif sfc == 'pgf90':
    getarg = 'getarg-pgf.f90'
    _ = [ '-Mdclchkk', '-o' ]
    g = [ '-Ktrap=fp', '-Mbounds', '-g' ] + _
    t = [ '-Ktrap=fp', '-Mbounds' ] + _
    p = [ '-O', '-Mprof=func' ] + _
    O = [ '-fast' ] + _
elif sfc == 'pathf95':
    getarg = ''
    _ = [ '-o' ]
    g = [ '-g' ] + _
    t = [] + _
    p = [ '-O', '-p' ] + _
    O = [ '-i8', '-O3', '-OPT:Ofast', '-fno-math-errno' ] + _
elif sfc == 'xlf95_r':
    getarg = ''
    _ = [ '-u', '-q64', '-qsuppress=cmpmsg', '-qlanglvl=2003pure', '-qsuffix=f=f90', '-o' ]
    g = [ '-C', '-qflttrap', '-qsigtrap', '-g' ] + _
    t = [ '-C', '-qflttrap', '-qsigtrap' ] + _
    p = [ '-O', '-p' ] + _
    O = [ '-O4' ] + _ # -O3 is much slower
elif sfc == 'f95' and os.uname()[0] == 'SunOS':
    getarg = 'getarg.f90'
    _ = [ '-u', '-o' ]
    g = [ '-C', '-ftrap=common', '-w4', '-g' ] + _
    t = [ '-C', '-ftrap=common'  ] + _
    p = [ '-O', '-pg' ] + _
    O = [ '-fast', '-fns' ] + _
if sfc: sfc = [ sfc ]
if mfc: mfc = [ mfc ]

