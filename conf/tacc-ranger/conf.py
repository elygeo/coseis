notes = """
TACC Ranger

http://www.tacc.utexas.edu/services/userguides/ranger/
ppn must be one of (1, 2, 4, 8, 12, 15, 16)
qstat
showq
qdel
qconf -sql 
qconf -sq large
cat /share/sge/default/tacc/sge_esub_control
lfs quota -u <username> $HOME
lfs quota -u <username> $WORK
lfs quota -u <username> $SCRATCH
"""
login = 'tg-login.ranger.tacc.teragrid.org'
hosts = [ 'login3.ranger.tacc.utexas.edu', 'login4.ranger.tacc.utexas.edu' ]
queue = 'request';     maxnodes = 1024; maxtime = 24, 00
queue = 'serial';      maxnodes = 1;    maxtime =  2, 00
queue = 'development'; maxnodes = 16;   maxtime =  2, 00
queue = 'large';       maxnodes = 1024; maxtime = 24, 00
queue = 'normal';      maxnodes = 256;  maxtime = 24, 00
maxcores = 16
maxram = 30000
rate = 2.1e6
fortran_serial = [ 'pgf95' ]
fortran_mpi = [ 'mpif90' ]
_ = [ '-Mdclchk', '-o' ]
fortran_flags = {
    'g': [ '-Ktrap=fp', '-Mbounds', '-g' ] + _,
    't': [ '-Ktrap=fp', '-Mbounds' ] + _,
    'p': [ '-fast', '-tp', 'barcelona-64', '-Mprof=func' ] + _,
    'O': [ '-fast', '-tp', 'barcelona-64' ] + _,
}

