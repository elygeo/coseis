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
"""

core_range = [1, 2, 4]
maxram = 2048
host_opts = {
    'challenger': {'maxnodes': 512,   'maxtime': 60,  'queue': 'prod-devel'},
    'surveyor':   {'maxnodes': 1024,  'maxtime': 60,  'queue': 'default'},
    'intrepid':   {'maxnodes': 40960, 'maxtime': 720, 'queue': 'prod'},
}

build_cc = 'mpixlcc_r -g -O5 -qlist -qreport -qsuppress=cmpmsg -qmaxmem=-1'
build_f90 = 'mpixlf2003_r -g -O5 -qlist -qreport -qsuppress=cmpmsg -qmaxmem=-1 -qlanglvl=2003pure'
build_ld = 'mpixlf2003_r -g -O'
build_omp = '-qsmp=omp'
build_prof = '-g -pg'
build_debug = '-g -O0 -C'
build_real8 = '-qrealsize=8'
build_libs = '/home/morozov/lib/libmpihpm.a'

launch = 'cobalt-mpirun -mode vn -verbose 2 -np {nproc} {command}'
launch = 'cobalt-mpirun -mode smp -verbose 2 -np {nproc} -env OMP_NUM_THREADS={cores} {command}'
submit = 'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script {name}.sh'
submit2 = 'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"'
 
