"""
ALCF IBM Blue Gene/Q Systems

Login:
ssh vesta.alcf.anl.gov

File systems:
/gpfs/vesta_scratch/projects/<ProjectName>

.soft:
PYTHONPATH += $HOME/coseis
PATH += $HOME/coseis/bin
PATH += /gpfs/vesta_home/gely/$ARCH/bin
MANPATH += /gpfs/vesta_home/gely/$ARCH/man
+mpiwrapper-xl.legacy
@default

Debug/profile:
bgq_stack <corefile>
coreprocessor <corefile>
VPROF_PROFILE=yes
/home/morozov/fixes/libc.a

Useful commands:
qstat
cbank
partlist
"""

maxcores = 16
maxnodes = 1024
maxram = 16 * 1024

compiler_c = 'mpixlcc_r'
compiler_f = 'mpixlf2003_r'
compiler_opts = {
    'f': '-u -qlanglvl=2003pure',
    'g': '-C -qfloat=nofold -qflttrap -qsigtrap -g',
    'g': '-C -qfloat=nofold -qflttrap -g',
    't': '-C -qflttrap',
    'p': '-O3 /home/morozov/HPM/lib/libmpihpm.a',
    'O': '-O3',
    '8': '-qrealsize=8',
}

launch = {
    's_exec':  'runjob --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB --envs PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE -p 1 -n 1 : {command}',
    'm_exec':  'runjob --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB --envs PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE -p {ppn} -n {nproc} : {command}',
    'submit':  'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 "{name}.sh"',
    'submit2': 'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 --dependenices {depend} "{name}.sh"',
}

