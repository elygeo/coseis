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

# MPI
nthread = 1
ppn_range = [1, 2, 4, 8, 16, 32]
build_flags = '-g -O3'
build_libs = '-lSPI_upci_cnk /home/morozov/fixes/libc.a /home/morozov/HPM/lib/libmpihpm.a /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a'
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE VPROF_PROFILE=yes\n'

# MPI + OpenMP
nthread = 32
ppn_range = [1]
build_flags = '-g -O3 -qsmp=omp'
build_libs = '-lSPI_upci_cnk /home/morozov/fixes/libc.a /home/morozov/HPM/lib/libmpihpm_smp.a /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a'
launch = 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE VPROF_PROFILE=yes OMP_NUM_THREADS={nthread}\n'

# compiler commands
build_cc = 'mpixlcc_r -qlist -qreport -qsuppress=cmpmsg'
build_fc = 'mpixlf2003_r -qlist -qreport -qsuppress=cmpmsg'
build_ld = 'mpixlf2003_r'
build_prof = '-pg'
build_debug = '-O0 -qfloat=nofold -qlanglvl=2003pure'
build_real8 = '-qrealsize=8'

# job submission
submit =  'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes "{name}.sh"'
submit =  'qsub "{name}.sh" -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes "{name}.sh"'
submit2 = 'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1:VPROF_PROFILE=yes --dependenices {depend} "{name}.sh"'

