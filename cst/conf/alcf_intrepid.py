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
    'm_exec':  'cobalt-mpirun -np {nproc} -mode vn --verbose 2 {command}',
    'submit':  'qsub -O {name} -n {nodes} -t {minutes} --mode script {name}.sh',
    'submit2': 'qsub -O {name} -n {nodes} -t {minutes} --mode script --dependenices {depend} "{name}.sh"',
}

