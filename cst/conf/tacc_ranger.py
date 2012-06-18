"""
TACC Ranger: Sun Constellation

.bashrc:
export PATH=/share/home/00967/gely/local/python/bin:${PATH}
export PATH=${HOME}/coseis/bin:${PATH}
export PYTHONPATH=${HOME}/coseis

.profile_user:
module unload mvapich pgi
module load intel mvapich
module load git
"""

core_range = [1, 2, 4, 8, 12, 15, 16]
maxram = 32768
rate = 12e5

queue_opts = [
    ('development', {'maxnodes': 16,   'maxtime':  120}),
    ('normal',      {'maxnodes': 256,  'maxtime': 1440}),
    ('large',       {'maxnodes': 1024, 'maxtime': 1440}),
    ('long',        {'maxnodes': 256,  'maxtime': 2880}),
    ('serial',      {'maxnodes': 1,    'maxtime':  120}),
    ('vis',         {'maxnodes': 2,    'maxtime': 1440}),
    ('request', {}),
]

# PGI compilers
f2py_flags = ''
build_cc = 'mpicc -Mdclchk -fast -tp barcelona-64'
build_f90 = 'mpif90 -Mdclchk -fast -tp barcelona-64'
build_ld = 'mpif90 -Mdclchk -fast -tp barcelona-64'
build_omp = 'FIXME'
build_prof = '-g -Mprof=func'
build_debug = '-g -Ktrap=fp -Mbounds'
build_real8 = '-Mr8'

# intel compilers
f2py_flags = '--fcompiler=intelem'
build_cc = 'mpicc -warn-O2 -xW'
build_f90 = 'mpif90 -warn -O2 -xW -u -std03'
build_ld = 'mpif90 -warn -O2 -xW -u -std03'
build_omp = 'FIXME'
build_prof = '-g -pg'
build_debug = '-g -CB -traceback'
build_real8 = '-r8'

launch = 'ibrun -n {nproc} -o 0 {command}'
launch = 'ibrun {command}'
submit = 'qsub "{name}.sh"'
submit2 = 'qsub -hold_jid "{depend}" "{name}.sh"'

