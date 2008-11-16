notes = """
TACC Ranger

http://www.tacc.utexas.edu/services/userguides/ranger/
ppn must be one of (1, 2, 4, 8, 12, 15, 16)
qstat
showq
qdel
qconf -sql 
lfs quota -u <username> $HOME
lfs quota -u <username> $WORK
lfs quota -u <username> $SCRATCH
"""
login = 'tg-login.ranger.tacc.teragrid.org'
hosts = [ 'login3.ranger.tacc.utexas.edu' ]
queue = 'request';     nodes = 1024; timelimit = 24, 00
queue = 'serial';      nodes = 1;    timelimit =  2, 00
queue = 'development'; nodes = 16;   timelimit =  2, 00
queue = 'large';       nodes = 768;  timelimit = 24, 00
queue = 'normal';      nodes = 256;  timelimit = 24, 00
cores = 16
ram = 30000
rate = 2.1e6
sfc = [ 'pgf95' ]
mfc = [ 'mpif90' ]
getarg = 'getarg-pgf.f90'
_ = [ '-Mdclchk', '-o' ]
g = [ '-Ktrap=fp', '-Mbounds', '-g' ] + _
t = [ '-Ktrap=fp', '-Mbounds' ] + _
p = [ '-fast', '-tp', 'barcelona-64', '-Mprof=func' ] + _
O = [ '-fast', '-tp', 'barcelona-64' ] + _

