notes = """
UCB Baribu cluster
"""
login = 'baribu.geo.berkeley.edu'
hosts = login,
maxnodes = 7
maxcores = 8
maxram = 30000
launch = {
    's_exec':  '%(bin)s',
    's_debug': 'gdb %(bin)s',
    'm_exec':  'mpiexec -np %(nproc)s %(bin)s',
    'm_debug': 'mpiexec -np %(nproc)s -gdb %(bin)s',
}

