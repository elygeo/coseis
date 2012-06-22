"""
NICS Kraken: Cray XT5
"""

# machine properties
maxnodes = 64 * 129
maxcores = 12
maxram = 16384
maxtime = 1440
rate = 1e6

# compilers
build_cc = 'cc'
build_fc = 'ftn -Mdclchk'
build_ld = 'ftn'
build_mpi = True

# MPI
build_flags = '-fast'
ppn_range = []
nthread = 1
launch = 'aprun -n {nproc} {command}'

# MPI + OpenMP
build_flags = '-mp -g -Ktrap=fp -Mbounds -Mchkptr'
build_flags = '-mp -fast -g -pg -Mprof=func'
build_flags = '-mp -fast -Mr8'
build_flags = '-mp -fast'
ppn_range = [1]
nthread = 12
launch = 'OMP_NUM_THREAD={nthread} aprun -d {nthread} n {nproc} {command}\n'

