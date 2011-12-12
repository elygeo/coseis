"""
UCB Baribu cluster
"""
login = hostname = 'baribu.geo.berkeley.edu'
maxnodes = 7
maxcores = 8
maxram = 30000
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpiexec -n {nproc} {command}',
    'm_debug': 'mpiexec -n {nproc} -gdb {command}',
}

