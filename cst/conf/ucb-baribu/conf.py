notes = """
UCB Baribu cluster
"""
login = 'baribu.geo.berkeley.edu'
hosts = login,
maxnodes = 7
maxcores = 8
maxram = 30000
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'mpiexec -np %(nproc)s %(command)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(command)s',
}

