notes = """
TACC Ranger
lfs quota -u <username> $HOME
lfs quota -u <username> $WORK
lfs quota -u <username> $SCRATCH
"""
login = 'tg-login.ranger.tacc.teragrid.org'
hosts = [ 'login3.ranger.tacc.utexas.edu' ]
nodes = 3936 # total
nodes = 16   # development
nodes = 256  # normal
nodes = 1024 # Request
nodes = 768  # large
cores = 16
ram = 30000
rate = 500
timelimit = 24, 00
sfc = [ 'pgf95' ]
mfc = [ 'mpif90' ]
getarg = 'getarg-pgf.f90'
_ = [ '-Mdclchk', '-o' ]
g = [ '-Ktrap=fp', '-Mbounds', '-g' ] + _
t = [ '-Ktrap=fp', '-Mbounds' ] + _
p = [ '-fast', '-tp', 'barcelona-64', '-Mprof=func' ] + _
O = [ '-fast', '-tp', 'barcelona-64' ] + _

