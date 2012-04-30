"""
ALCF Cetus

/cetus-fs0/
"""
login = hostname = '*.alcf.anl.gov'
maxcores = 4
maxnodes = 1024
maxram = 1000
fortran_serial = 'xlf2008_r'
fortran_mpi = 'xlf2008_r'
fortran_flags = {
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure -qsuffix=f=f90',
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure',
    'f': '-u -qlanglvl=2003pure',
    'g': '-C ‐qsmp=omp:noopts:noauto ‐qfloat=nofold -qflttrap -qsigtrap -g',
    'g': '-C ‐qsmp=omp:noopts:noauto ‐qfloat=nofold -qflttrap -g',
    't': '-C -qsmp=omp:noauto -qflttrap',
    'p': '-O -qsmp=omp:noauto -p',
    'O': '-O3 -qsmp=omp:noauto',
    '8': '-qrealsize=8',
}
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'cobalt-mpirun -np {nproc} {command}',
    'submit':  'qsub -n {nnode} --proccount {nproc} --mode c16 -t {minutes} -A {project} --env BG_SHAREDMEMSIZE=32MB:PAMI_VERBOSE=1 {name}.sh',
    'submit2': 'qsub -n {nnode} --proccount {nproc} --mode c16 -t {minutes} -A {project} --env BG_SHAREDMEMSIZE=32MB:PAMI_VERBOSE=1 --dependenices {depend} "{name}.sh"',
}

