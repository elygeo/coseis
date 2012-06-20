"""
NICS Kraken: Cray XT5
"""

# MPI
nthread = 1
ppn_range = []
build_flags = '-fast'
launch = 'aprun -n {nproc} {command}'

# MPI + OpenMP
nthread = 12
ppn_range = [1]
build_flags = '-fast -mp'
launch = 'OMP_NUM_THREAD={nthread} aprun -d {nthread} n {nproc} {command}'

# compiler options
build_mpi = True
build_cc = 'cc'
build_fc = 'ftn -Mdclchk'
build_ld =  'ftn'
build_prof = '-g -pg -Mprof=func'
build_debug = '-g -Ktrap=fp -Mbounds -Mchkptr'
build_real8 = '-Mr8'

# job submission
submit = 'qsub "{name}.sh"'
submit2 = 'qsub -W depend="afterok:{depend}" "{name}.sh"'

# machine properties
maxnodes = 64 * 129
maxcores = 12
maxram = 16384
maxtime = 1440
rate = 1e6

