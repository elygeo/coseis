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

# machine properties
maxnodes = 1024
maxcores = 16
maxram = 16384

# compilers
build_cc = 'mpixlcc_r -qlist -qreport -qsuppress=cmpmsg'
build_fc = 'mpixlf2003_r -qlist -qreport -qsuppress=cmpmsg'
build_ld = 'mpixlf2003_r'

# MPI
build_flags = '-g -O3'
build_libs = '-lSPI_upci_cnk /home/morozov/fixes/libc.a /home/morozov/HPM/lib/libmpihpm.a /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a'
ppn_range = [1, 2, 4, 8, 16, 32]
nthread = 1
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE VPROF_PROFILE=yes\n'

# MPI + OpenMP
build_flags = '-g -O0 -qsmp=omp -qfloat=nofold -qlanglvl=2003pure'
build_flags = '-g -O3 -qsmp=omp -qrealsize=8'
build_flags = '-g -O3 -qsmp=omp'
build_libs = '-lSPI_upci_cnk /home/morozov/fixes/libc.a /home/morozov/HPM/lib/libmpihpm_smp.a /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a'
ppn_range = [1]
nthread = 32
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE VPROF_PROFILE=yes OMP_NUM_THREADS={nthread}\n'

# job submission
notify = '-M {email}'
submit =  'qsub {notify} -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes {submit_flags} "{name}.sh"'
submit2 = 'qsub {notify} -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes --dependenices {depend} {submit_flags} "{name}.sh"'

