"""
KAUST Shaheen: IBM Blue Gene/P

ssh shaheen.hpc.kaust.edu.sa
http://www.hpc.kaust.edu.sa/

Requirements:
module load GNU
module load numpy
"""

account = 'k33'
maxcores = 4
maxram = 4 * 1024
queue = 'default'

queue_opts = [
    ('development', {'maxnodes':  8 * 1024, 'maxtime':      30}),
    ('pset64',      {'maxnodes':  4 * 1024, 'maxtime': 24 * 60}),
    ('pset128',     {'maxnodes': 12 * 1024, 'maxtime': 24 * 60}),
    ('default',     {'maxnodes': 16 * 1024, 'maxtime': 24 * 60}),
]

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpirun -mode VN -np {nproc} -exe {command}',
    'submit':  'llsubmit "{name}.sh"',
}

