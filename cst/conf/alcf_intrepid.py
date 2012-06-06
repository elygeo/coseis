"""
ALCF

/intrepid-fs0/ cross-mounted with Challenger and Eureka

Useful:
    cbank
    projects
    bg-listjobs

.basshrc
    PS1="[\u@${mybgp}:\w]\$ "
    export LC_COLLATE=C

.softevnrc
    PYTHONPATH += $HOME/coseis
    PATH += $HOME/coseis/bin
    PATH += /gpfs/home/gely/local/$HOSTTYPE/bin
    PATH += /bgsys/drivers/ppcfloor/comm/xl/bin
    +git-1.7.6.4

/bgsys/drivers/ppcfloor/gnu-linux/bin
--env LD_LIBRARY_PATH=/bgsys/drivers/ppcfloor/gnu-linux/lib /bgsys/drivers/ppcfloor/gnu-linux/bin/python
"""

login = 'intrepid.alcf.anl.gov'
hostname = 'login[0-9]'
maxcores = 4
maxram = 2 * 1024
maxnodes = 40 * 1024
maxtime = 12 * 60
queue = 'prod'

fortran_serial = '/bgsys/drivers/ppcfloor/comm/xl/bin/mpixlf2003_r'
fortran_mpi = '/bgsys/drivers/ppcfloor/comm/xl/bin/mpixlf2003_r'

fortran_flags = {
    'f': '-qlanglvl=2003pure',
    'g': '-C -u -O0 -g',
    't': '-C',
    'p': '-O -p',
    'O': '-O -qarch=450d -qtune=450',
    '8': '-qrealsize=8',
}

# -A project -O name
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'cobalt-mpirun -np {nproc} -mode vn -verbose 2 {command}',
    'submit':  'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script {name}.sh',
    'submit2': 'qsub -O {name} -A {account} -q {queue} -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"',
}

