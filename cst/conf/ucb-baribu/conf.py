"""
UCB Baribu cluster
"""
login = hostname = 'baribu.geo.berkeley.edu'
maxnodes = 7
maxcores = 8
maxram = 30000
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'mpiexec -n %(nproc)s %(command)s',
    'm_debug': 'mpiexec -n %(nproc)s -gdb %(command)s',
}

