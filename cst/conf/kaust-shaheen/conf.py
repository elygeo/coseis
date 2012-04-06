"""
KAUST Shaheen
http://www.hpc.kaust.edu.sa/

Requirements:
module load GNU
module load numpy
"""
login = hostname = 'shaheen.hpc.kaust.edu.sa'
maxcores = 4
maxnodes = 16384
maxram = 3800
fortran_serial = 'gfortran'
fortran_mpi = 'mpif90'
queue = 'default'
queue_opts = [
    {'queue': 'development', 'maxnodes': 8192,  'maxtime':  (0, 30)},
    {'queue': 'pset64',      'maxnodes': 4096,  'maxtime': (24, 00)},
    {'queue': 'pset128',     'maxnodes': 12288, 'maxtime': (24, 00)},
    {'queue': 'default',     'maxnodes': 16384, 'maxtime': (24, 00)},
]
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'submit':  'llsubmit "{name}.sh"',
}

