"""
ALCF Cetus

/cetus-fs0/

echo '+mpiwrapper-xl' >> .soft
"""
login = hostname = '*.alcf.anl.gov'
maxcores = 16
maxnodes = 1024
maxram = 1000
fortran_serial = 'xlf2008_r'
fortran_mpi = 'mpixlf2003_r'
fortran_flags = {
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure -qsuffix=f=f90',
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure',
    'f': '-u -qlanglvl=2003pure',
    'g': '-C -qsmp=omp:noopts:noauto -qfloat=nofold -qflttrap -qsigtrap -g',
    'g': '-C -qsmp=omp:noopts:noauto -qfloat=nofold -qflttrap -g',
    't': '-C -qsmp=omp:noauto -qflttrap',
    'p': '-O -qsmp=omp:noauto -p',
    'O': '-O3 -qsmp=omp:noauto',
    '8': '-qrealsize=8',
}
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec': 'runjob -p {ppn} -n {nproc} --verbose 2 --block $COBALT_PARTNAME' + \
        '  --envs BG_SHAREDMEMSIZE=32MB --envs PAMI_VERBOSE=1' + \
        '  ${COBALT_CORNER:+--corner} $COBALT_CORNER ${COBALT_SHAPE:+--shape} $COBALT_SHAPE' + \
        '  : {command}',
    'submit': 'qsub -t {minutes} -n {nnode} -A {project}' + \
        '  --env BG_SHAREDMEMSIZE=32MB:PAMI_VERBOSE=1' + \
        '  --mode script "{name}.sh"',
    'submit2': 'qsub -t {minutes} -n {nnode} -A {project}' + \
        '  --env BG_SHAREDMEMSIZE=32MB:PAMI_VERBOSE=1' + \
        '  --mode script --dependenices "{name}.sh"',
}

