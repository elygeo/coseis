"""
ALCF IBM Blue Gene/Q

vesta.alcf.anl.gov /gpfs/vesta_scratch/projects/

.soft:
PYTHONPATH += $HOME/coseis
PATH += $HOME/coseis/bin
PATH += /gpfs/vesta_home/gely/local-${ARCH##*-}/bin
MANPATH += /gpfs/vesta_home/gely/local-${ARCH##*-}/man
+mpiwrapper-xl.legacy
@default

useful:
qstat
cbank
partlist
myquota
myprojectquota
bgq_stack
coreprocessor
VPROF_PROFILE=yes
"""

core_range = [1, 2, 4, 8, 16]
maxnodes = 1024
maxram = 16384

compiler_c = 'mpixlcc_r'
compiler_f = 'mpixlf2003_r'
compiler_opts = {
    'f': '-qlanglvl=2003pure -qsuppress=cmpmsg',
    't': '-C',
    'g': '-C -O0 -qfloat=nofold -g',
    'O': '-O3 -qstrict /home/morozov/HPM/lib/libmpihpm.a',
    'h': '-O3 -qstrict /home/morozov/HPM/lib/libmpihpm.a',
    'p': '-O3 -qstrict /home/morozov/HPM/lib/libmpihpm.a -g -pg',
    '8': '-qrealsize=8',
}

launch = {
    'exec': 'runjob --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB --envs PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE -p {cores} -n {nproc} : {command}\n',
    'submit':  'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 "{name}.sh"',
    'submit2': 'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 --dependenices {depend} "{name}.sh"',
}

