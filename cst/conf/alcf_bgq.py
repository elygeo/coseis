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

core_range = [1, 2, 4, 8, 16, 32]
maxnodes = 1024
maxram = 16384

build_cc = 'mpixlcc_r -qlist -qreport -qsuppress=cmpmsg'
build_fc = 'mpixlf2003_r -qlist -qreport -qsuppress=cmpmsg'
build_ld = 'mpixlf2003_r'
build_omp = '-qsmp=omp'
build_flags = '-g -O3'
build_prof = '-g -pg'
build_debug = '-g -O0 -qfloat=nofold -qlanglvl=2003pure'
build_real8 = '-qrealsize=8'
build_libs = '-lSPI_upci_cnk /home/morozov/HPM/lib/libmpihpm.a /bgsys/drivers/ppcfloor/bgpm/lib/libbgpm.a'

launch = 'runjob --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB --envs PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE -n {nproc} -p 1 --envs OMP_NUM_THREADS={nthread} : {command}\n'

launch = 'runjob --verbose=INFO --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB --envs PAMID_VERBOSE=1 ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE -n {nproc} -p {nthread} : {command}\n'

submit =  'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 "{name}.sh"'

submit2 = 'qsub -O {name} -A {account} -n {nodes} -t {minutes} --mode script --env BG_SHAREDMEMSIZE=32MB:PAMID_VERBOSE=1 --dependenices {depend} "{name}.sh"'

