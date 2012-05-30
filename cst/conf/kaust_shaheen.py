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
    ('development', {'maxnodes': 8192,  'maxtime':  (0, 30)}),
    ('pset64',      {'maxnodes': 4096,  'maxtime': (24, 00)}),
    ('pset128',     {'maxnodes': 12288, 'maxtime': (24, 00)}),
    ('default',     {'maxnodes': 16384, 'maxtime': (24, 00)}),
]

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'script':  'mpirun -mode VN -np {nproc} -exe {command}',
    'submit':  'llsubmit "{name}.sh"',
}

script_header = """\
#!/bin/sh
# @ account_no = k33
# @ class = {queue}
# @ job_name = {name}
# @ bg_size = {nodes}
# @ wall_clock_limit = {walltime}
# @ error = {name}-err
# @ output = {name}-out
# @ initialdir = {rundir}
# @ notify_user = {email}
# @ notification = never
# @ job_type = bluegene
# @ environment = COPY_ALL
# @ queue
"""

