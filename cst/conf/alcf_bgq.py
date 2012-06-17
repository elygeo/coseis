"""
ALCF IBM Blue Gene/Q

install location:
vesta.alcf.anl.gov:/gpfs/vesta_scratch/projects/

.soft:
PYTHONPATH += $HOME/coseis
PATH += $HOME/coseis/bin
PATH += /gpfs/vesta_home/gely/local-${ARCH##*-}/bin
MANPATH += /gpfs/vesta_home/gely/local-${ARCH##*-}/man
+mpiwrapper-xl.legacy
@default
"""

core_range = [1, 2, 4, 8, 16]
maxnodes = 1024
maxram = 16384

compiler_cc = 'mpixlcc_r'
compiler_f90 = 'mpixlf2003_r'
compiler_opts = {
    'f': '-qlanglvl=2003pure -qsuppress=cmpmsg -qreport',
    'g': '-C -g -O0 -qfloat=nofold',
    'O': '-O3 -qsimd=auto',
    'O': '-O3 /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a /home/morozov/HPM/lib/libmpihpm.a -g',
    'p': '-O3 /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a /home/morozov/HPM/lib/libmpihpm.a -g -pg',
    'm': '-qsmp=noauto',
    '8': '-qrealsize=8',
}

launch = {
    'exec': 'runjob --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB --envs PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE -p {cores} -n {nproc} : {command}\n',
    'submit':  'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 "{name}.sh"',
    'submit2': 'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 --dependenices {depend} "{name}.sh"',
}

