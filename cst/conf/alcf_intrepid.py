"""
ALCF

/intrepid-fs0/ cross-mounted on Challenger and Eureka

.softevnrc
    PYTHONPATH += $HOME/coseis
    PATH += $HOME/coseis/bin
    PATH += /gpfs/home/gely/$ARCH/bin
    MANPATH += /gpfs/home/gely/$ARCH/man
    PATH += /bgsys/drivers/ppcfloor/comm/xl/bin
    +git-1.7.6.4

.basshrc
    PS1="[\u@${mybgp}:\w]\$ "

Useful commands:
    cbank
    projects
    bg-listjobs
"""

login = 'intrepid.alcf.anl.gov'
hostname = 'login[0-9]'
maxcores = 4
maxram = 2 * 1024
maxnodes = 40 * 1024
maxtime = 12 * 60
queue = 'prod'

fortran_serial = 'mpixlf2003_r'
#fortran_mpi = 'mpixlf2003_r mpi.f90'
fortran_mpi = 'mpixlf2003_r'

fortran_flags = {
    'f': '-qlanglvl=2003pure -qsuppress=cmpmsg',
    'g': '-C -u -O0 -g',
    't': '-C',
    'p': '-O -p /home/morozov/lib/libmpihpm.a',
    'O': '-O -qarch=450d -qtune=450',
    '8': '-qrealsize=8',
}

launch = {
    's_exec':  'cobalt-mpirun -mode vn -verbose 2 -np 1 {command}',
    'm_exec':  'cobalt-mpirun -mode vn -verbose 2 -np {nproc} {command}',
    'submit':  'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script {name}.sh',
    'submit2': 'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"',
}

