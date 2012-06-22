"""
ALCF IBM Blue Gene/P

install location:
challenger.alcf.anl.gov:/intrepid-fs0/$USER/persistent

.softevnrc:
PYTHONPATH += $HOME/coseis
PATH += $HOME/coseis/bin
PATH += /gpfs/home/gely/local-$HOSTTYPE/bin
MANPATH += /gpfs/home/gely/local-$HOSTTYPE/man
PATH += /bgsys/drivers/ppcfloor/comm/xl/bin
+git-1.7.6.4
+tau-latest
TAU_MAKEFILE = /soft/apps/tau/tau_latest/bgp/lib/Makefile.tau-bgptimers-mpi-pdt
TAU_OPTIONS = '-optVerbose -optNoRevert -optCompInst'
"""

# machine properties
maxcores = 4
maxram = 2048
host_opts = {
    'challenger': {'maxnodes': 512,   'maxtime': 60,  'queue': 'prod-devel'},
    'surveyor':   {'maxnodes': 1024,  'maxtime': 60,  'queue': 'default'},
    'intrepid':   {'maxnodes': 40960, 'maxtime': 720, 'queue': 'prod'},
}

# TAU
build_cc = 'tau_cc.sh -qlist -qreport -qsuppress=cmpmsg'
build_fc = 'tau_f90.sh -qlist -qreport -qsuppress=cmpmsg'
build_ld = 'tau_f90.sh'
build_libs = ''
launch = 'cobalt-mpirun -mode vn -verbose 2 -np {nproc} -env "TAU_METRICS=BGPTIMERS" {command}'

# HPM
build_cc = 'mpixlcc_r -qlist -qreport -qsuppress=cmpmsg'
build_fc = 'mpixlf2003_r -qlist -qreport -qsuppress=cmpmsg'
build_ld = 'mpixlf2003_r'

# MPI
build_flags = '-g -O3'
build_libs = '/home/morozov/lib/libmpihpm.a'
ppn_range = [1, 2, 4]
nthread = 1
launch = 'cobalt-mpirun -mode vn -verbose 2 -np {nproc} {command}'

# MPI + OpenMP
build_flags = '-g -O0 -qsmp=omp -C -qlanglvl=2003pure'
build_flags = '-g -O3 -qsmp=omp -qrealsize=8'
build_flags = '-g -O3 -qsmp=omp'
build_libs = '/home/morozov/lib/libmpihpm_smp.a'
ppn_range = [1]
nthread = 4
launch = 'cobalt-mpirun -mode smp -verbose 2 -np {nproc} -env OMP_NUM_THREADS={nthread} {command}'

# job submission
notify = '-M {email}'
submit = 'qsub {notify} -O {code} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script {submit_flags} {code}.sh'
submit2 = 'qsub {notify} -O {code} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script --dependenices {depend} {submit_flags} "{code}.sh"'
 
