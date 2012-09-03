"""
NICS Kraken: Cray XT5
"""

# machine properties
account = 'TG-MCA03S012'
maxnodes = 64 * 129
maxcores = 12
maxram = 16384
maxtime = 1440
rate = 1e6

# MPI
build_ldflags = '-fast'
ppn_range = []
nthread = 1
launch = 'aprun -n {nproc} {command}'

# MPI + OpenMP
build_ldflags = '-mp -g -Ktrap=fp -Mbounds -Mchkptr'
build_ldflags = '-mp -fast -g -pg -Mprof=func'
build_ldflags = '-mp -fast'
ppn_range = [1]
nthread = 12
launch = 'OMP_NUM_THREAD={nthread} aprun -d {nthread} n {nproc} {command}\n'

# compilers
build_cc = 'cc'
build_fc = 'ftn'
build_ld = 'ftn'
build_mpi = True
build_cflags = build_ldflags
build_fflags = build_ldflags +  ' -Mdclchk -Mr8'
build_fflags = build_ldflags +  ' -Mdclchk'

