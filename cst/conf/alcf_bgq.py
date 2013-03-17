"""
ALCF IBM Blue Gene/Q

install location:
mira.alcf.anl.gov:/gpfs/mira-fs0/projects/

.soft:
PYTHONPATH += $HOME/coseis
PATH += $HOME/coseis/bin
PATH += /home/gely/local/${ARCH##*-}/epd/bin
PATH += /home/gely/local/${ARCH##*-}/bin
MANPATH += /home/gely/local/${ARCH##*-}/man
+mpiwrapper-xl
@default
"""

# account name (override in site.py if needed).
account = 'GroundMotion_esp'

# machine properties
maxcores = 16
maxram = 16384
host_opts = {
    'vesta': {'maxnodes': 1024,  'maxtime': 120},
    'cetus': {'maxnodes': 1024,  'maxtime': 120},
    'mira':  {'maxnodes': 49152, 'maxtime': 720},
}

# MPI
build_ldflags = '-g -O3 -qsuppress=cmpmsg'
build_libs = '-lSPI_upci_cnk /home/morozov/HPM/lib/libmpihpm.a /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a'
ppn_range = [1, 2, 4, 8, 16, 32]
nthread = 1
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 VPROF_PROFILE=yes\n'

# MPI + OpenMP
build_ldflags = '-g -O0 -qsmp=omp:noauto -qsuppress=cmpmsg -qfloat=nofold'
build_ldflags = '-g -O3 -qsmp=omp:noauto -qsuppress=cmpmsg'
build_libs = '-lSPI_upci_cnk /home/morozov/HPM/lib/libmpihpm_smp.a /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a'
ppn_range = [1]
nthread = 32
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 VPROF_PROFILE=yes OMP_NUM_THREADS={nthread}\n'

# compilers
build_cc = 'mpixlc_r'
build_fc = 'mpixlf2003_r'
build_ld = 'mpixlf2003_r'
build_fflags = build_ldflags + ' -qlist -qreport -qrealsize=8'
build_fflags = build_ldflags + ' -qlist -qreport'
build_cflags = build_ldflags + ' -qlist -qreport'

# job submission
notify = '-M {email}'
submit =  'qsub {notify} -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes {submit_flags} "{name}.sh"'
submit2 = 'qsub {notify} -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes --dependenices {depend} {submit_flags} "{name}.sh"'

