"""
KAUST Shaheen: IBM Blue Gene/P

module load GNU
module load numpy
"""

account = 'k33'
core_range = [1, 2, 4]
maxram = 4096
queue = 'default'

queue_opts = [
    ('development', {'maxnodes':  8 * 1024, 'maxtime':   30}),
    ('pset64',      {'maxnodes':  4 * 1024, 'maxtime': 1440}),
    ('pset128',     {'maxnodes': 12 * 1024, 'maxtime': 1440}),
    ('default',     {'maxnodes': 16 * 1024, 'maxtime': 1440}),
]

launch = 'mpirun -mode VN -np {nproc} -exe {command}'
submit = 'llsubmit "{name}.sh"'

