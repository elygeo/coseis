notes = """
UCB Baribu cluster
"""
login = 'baribu.geo.berkeley.edu'
hosts = login,
maxnodes = 7
maxcores = 8
maxram = 30000
launch = {
    's-exec':  '%(bin)s',
    's-debug': 'gdb %(bin)s',
    'm-exec':  'mpiexec -np %(nproc)s %(bin)s',
    'm-debug': 'mpiexec -np %(nproc)s -gdb %(bin)s',
}

