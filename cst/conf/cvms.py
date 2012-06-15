"""
CVM configuration
"""

version = '4.0'
minutes = 20
nsample = None
file_lon = 'hold/lon.bin'
file_lat = 'hold/lat.bin'
file_dep = 'hold/dep.bin'
file_rho = 'hold/rho.bin'
file_vp = 'hold/vp.bin'
file_vs = 'hold/vs.bin'
stagein = ['hold/']

# command line options: (short, long, parameter, value)
options = [
    ('v', 'verbose',     'verbose',  True),
    ('n', 'dry-run',     'prepare',  False),
    ('f', 'force',       'force',    True),
    ('i', 'interactive', 'run',      'exec'),
    ('d', 'debug',       'run',      'debug'),
    ('b', 'batch',       'run',      'submit'),
    ('q', 'queue',       'run',      'submit'),
]

compiler_opts = {
    'gnu': {
        'g': '-Wall -fbounds-check -ffpe-trap=invalid,zero,overflow -g',
        'O': '-Wall -O3',
    },
    'intel': {
        'g': '-std95 -warn -CB -traceback -g',
        'O': '-std95 -warn -O3',
    },
    'ibm': {
        'g': '-q64 -qsuppress=cmpmsg -qfixed -C -qflttrap -qsigtrap -g',
        'O': '-q64 -qsuppress=cmpmsg -qfixed -O4',
    },
    'pgi': {
        'g': '-Ktrap=fp -Mbounds -g',
        'O': '-fast',
    },
    'sun': {
        'g': '-u -C -ftrap=common -w4 -g',
        'O': '-u -O2 -w1', # anything higher than -O2 breaks it
    },
}

