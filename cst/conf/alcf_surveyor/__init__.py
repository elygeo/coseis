"""
ALCF

bg-listjobs
partlist

/pvfs-surveyor/

/bgsys/drivers/ppcfloor/gnu-linux/bin
--env LD_LIBRARY_PATH=/bgsys/drivers/ppcfloor/gnu-linux/lib /bgsys/drivers/ppcfloor/gnu-linux/bin/python
"""

login = hostname = '.*.alcf.anl.gov'
maxcores = 4
maxnodes = 1024
maxram = 1900
queue = 'default'
maxtime = 1, 00
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
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'cobalt-mpirun -np {nproc} {command}',
    'submit':  'qsub -q {queue} -n {nproc} -t {minutes} "{script}"',
    'submit2': 'qsub -q {queue} -n {nproc} -t {minutes} --dependenices {depend} "{script}"',
}

