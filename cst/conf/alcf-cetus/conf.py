"""
ALCF Cetus

/cetus-fs0/
"""
login = hostname = '*.alcf.anl.gov'
maxcores = 4
maxnodes = 40960
maxram = 1900
queue = 'prod'
queue_opts = [
    ('prod-devel', {'maxnodes': 512,   'maxtime': (1, 00)}),
    ('prod',       {'maxnodes': 32768, 'maxtime': (12, 00)}),
]
fortran_serial = 'mpixlf90_r'
fortran_mpi = 'mpixlf90_r'
fortran_flags = {
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure -qsuffix=f=f90',
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure',
    'g': '-C -qflttrap -qsigtrap -O0 -g',
    'g': '-C -qflttrap -O0 -g',
    't': '-C -qflttrap',
    'p': '-O -p',
    'O': '-O3 -qsmp=omp:noauto',
    '8': '-qrealsize=8',
}
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'cobalt-mpirun -np {nproc} {command}',
    'submit':  'qsub -q {queue} -n {nproc} -t {minutes} {name}.sh',
    'submit2': 'qsub -q {queue} -n {nproc} -t {minutes} --dependenices {depend} "{name}.sh"',
}

