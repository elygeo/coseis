"""
TACC Ranger

EPD version: rh3-x86_64

export F77=pgf95
export F90=pgf95

gsiftp://gridftp.ranger.tacc.teragrid.org:2811/
http://www.tacc.utexas.edu/services/userguides/ranger/
ppn must be one of (1, 2, 4, 8, 12, 15, 16)

cat /share/sge/default/tacc/sge_esub_control
module list
qconf -sql
lfs quota -u $USER $HOME
lfs quota -u $USER $WORK
lfs quota -u $USER $SCRATCH

.profile
module unload mvapich
#module swap pgi gcc"
module load mvapich2
alias showme='showq -u'

# needed?
module load gotoblas scalapack mkl
"""
login = 'tg-login.ranger.tacc.teragrid.org'
hostname = 'login[34].ranger.tacc.utexas.edu'
queue = 'request';     maxnodes = 1024; maxtime = 24, 00
queue = 'serial';      maxnodes = 1;    maxtime =  2, 00
queue = 'development'; maxnodes = 16;   maxtime =  2, 00
queue = 'long';        maxnodes = 256;  maxtime = 48, 00
queue = 'large';       maxnodes = 1024; maxtime = 24, 00
queue = 'normal';      maxnodes = 256;  maxtime = 24, 00
maxcores = 16
maxram = 30000
rate = 2.1e6
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -hold_jid "%(depend)s" "%(name)s.sh"',
}
fortran_serial = 'pgf95'
fortran_mpi = 'mpif90'
fortran_flags = {
    'f': '-Mdclchk',
    'g': '-Ktrap=fp -Mbounds -g',
    't': '-Ktrap=fp -Mbounds',
    'p': '-fast -tp barcelona-64 -Mprof=func',
    'O': '-fast -tp barcelona-64',
    '8': '-Mr8',
}

# find pgf77 compiler
import os
for d in os.environ['PATH'].split(':'):
    f = os.path.join( d, 'pgf77' ) 
    if os.path.isfile( f ):
        f2py_flags = '--f77exec=' + f
        break

