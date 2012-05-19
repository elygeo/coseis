"""
TACC Ranger

EPD version: rh3-x86_64
mvapich2 supports MPI2, but not recommended for more than 2048 tasks.

.profile_user
module unload pgi
module load intel git

.bashrc
alias qme='showq -u'
alias qdev='idev -minutes 120'

gsiftp://gridftp.ranger.tacc.teragrid.org:2811/
http://www.tacc.utexas.edu/services/userguides/ranger/
ppn must be one of (1, 2, 4, 8, 12, 15, 16)

cat /share/sge/default/tacc/sge_esub_control
qconf -sql
lfs quota -u $USER $HOME
lfs quota -u $USER $WORK
lfs quota -u $USER $SCRATCH

# needed?
module load gotoblas scalapack mkl
export F77=ifort
export F90=ifort
"""

login = 'tg-login.ranger.tacc.teragrid.org'
hostname = '.*.ranger.tacc.utexas.edu'
maxcores = 16
maxram = 30000
#rate = 21e5
rate = 12e5
queue_opts = [
    ('development', {'maxnodes': 16,   'maxtime':  (2, 00)}),
    ('normal',      {'maxnodes': 256,  'maxtime': (24, 00)}),
    ('large',       {'maxnodes': 1024, 'maxtime': (24, 00)}),
    ('long',        {'maxnodes': 256,  'maxtime': (48, 00)}),
    ('serial',      {'maxnodes': 1,    'maxtime':  (2, 00)}),
    ('vis',         {'maxnodes': 2,    'maxtime': (24, 00)}),
    ('request', {}),
]
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'ibrun -n {nproc} -o 0 {command}',
    'm_debug': 'ddt -start -once -n {nproc} -- {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -hold_jid "{depend}" "{name}.sh"',
}
fortran_serial = 'ifort'
fortran_mpi = 'mpif90'
fortran_flags = {
    'f': '-u -std95 -warn',
    'g': '-CB -traceback -g',
    't': '-CB -traceback',
    'p': '-O -pg',
    'O': '-O2 -xW',
    '8': '-r8',
}
f2py_flags = '--fcompiler=intelem'

