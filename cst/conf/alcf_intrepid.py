"""
ALCF

/intrepid-fs0/ cross-mounted with Challenger and Eureka

Useful:
    projects
    bg-listjobs
    partlist
    cbank
    qalter


.basshrc
    PS1="[\u@${mybgp}:\w]\$ "
    export LC_COLLATE=C
    export PATH=${HOME}/local/${HOSTTYPE}/bin:${PATH}

/bgsys/drivers/ppcfloor/gnu-linux/bin
--env LD_LIBRARY_PATH=/bgsys/drivers/ppcfloor/gnu-linux/lib /bgsys/drivers/ppcfloor/gnu-linux/bin/python
"""

login = 'intrepid.alcf.anl.gov'
hostname = 'login[0-9]'
maxcores = 4
maxram = 1900
maxnodes = 40960
maxtime = 12, 00
queue = 'prod'

fortran_serial = 'mpixlf90_r'
fortran_mpi = 'mpixlf90_r'

fortran_flags = {
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure -qsuffix=f=f90',
    'f': '-u -qsuppress=cmpmsg -qlanglvl=2003pure',
    'g': '-C -qflttrap -qsigtrap -O0 -g',
    'g': '-C -qflttrap -O0 -g',
    't': '-C -qflttrap',
    'p': '-O -p',
    'O': '-O4 -qarch=450d -qtune=450',
    '8': '-qrealsize=8',
}

# -A project -O name
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'cobalt-mpirun -np {nproc} --mode vn --verbose 2 {command}',
    #'submit':  'qsub -O {name}-out -q {queue} -n {nodes} -t {minutes} -A {account} --mode script {name}.sh',
    'submit':  'qsub -O {name}-out -n {nodes} -t {minutes} --mode script {name}.sh',
    'submit2': 'qsub -O {name}-out -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"',
}

