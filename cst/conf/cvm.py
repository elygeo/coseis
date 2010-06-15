"""
CVM configuration
"""
seconds = 400
nsample = None
lon_file = 'lon'
lat_file = 'lat'
dep_file = 'dep'
rho_file = 'rho'
vp_file = 'vp'
vs_file = 'vs'

# command line options: (short, long, parameter, value)
options = [
    ( '',  'machine=',    'machine',  str ),
    ( 'n', 'dry-run',     'prepare',  False ),
    ( 'f', 'force',       'force',    True ),
    ( 'i', 'interactive', 'run',      'exec' ),
    ( 'd', 'debug',       'run',      'debug' ),
    ( 'b', 'batch',       'run',      'submit' ),
    ( 'q', 'queue',       'run',      'submit' ),
    ( 's', 'serial',      'mode',     's' ),
    ( 'm', 'mpi',         'mode',     'm' ),
]

# Fortran compiler flags
fortran_flags_default_ = {
    'gfortran': {
        'g': ('-Wall', '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g'),
        'O': ('-Wall', '-O3'),
    },
    'ifort': {
        'g': ('-u', '-std95', '-warn', '-CB', '-traceback', '-g'),
        'O': ('-u', '-std95', '-warn', '-O3'),
    },
    'xlf95_r': {
        'g': ('-q64', '-qsuppress=cmpmsg', '-qfixed', '-C', '-qflttrap', '-qsigtrap', '-g'),
        'O': ('-q64', '-qsuppress=cmpmsg', '-qfixed', '-O4'),
    },
    'pgf90': {
        'g': ('-Ktrap=fp', '-Mbounds', '-g'),
        'O': ('-fast',),
    },
    'pgf95': {
        'g': ('-Ktrap=fp', '-Mbounds', '-g'),
        'O': ('-fast',),
    },
    'pathf95': {
        'g': ('-g',),
        'O': ('-i8', '-O3', '-OPT:Ofast', '-fno-math-errno'),
    },
}
if os.uname()[0] == 'SunOS':
    fortran_flags_default_.update( {
        'f95': {
            'g': ('-u', '-C', '-ftrap=common', '-w4', '-g'),
            'O': ('-u', '-O2', '-w1'), # anything higher than -O2 breaks it
        }
    } )

