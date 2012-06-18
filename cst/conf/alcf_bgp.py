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

compiler_cc = 'mpixlcc_r'
compiler_f90 = 'mpixlf2003_r'
compiler_opts = {
    'f': '-qlanglvl=2003pure -qsuppress=cmpmsg -qmaxmem=-1 -qlist -qreport',
    'g': '-O0 -g -C',
    'O': '-O5',
    'O': '-O5 -g /home/morozov/lib/libmpihpm.a',
    'p': '-O5 -g -pg /home/morozov/lib/libmpihpm.a',
    'm': '-qsmp=omp',
    '8': '-qrealsize=8',
}

launch = {
    'exec': 'cobalt-mpirun -mode vn -verbose 2 -np {nproc} {command}',
    'omp': 'cobalt-mpirun -mode smp -verbose 2 -np {nproc} -env OMP_NUM_THREADS={cores} {command}',
    'submit':  'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script {name}.sh',
    'submit2': 'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"',
}

