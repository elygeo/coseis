"""
NICS Kraken: Cray XT5
"""

maxram = 16384
core_range = [12]
maxnodes = 64 * 129
maxtime = 1440
rate = 1e6

build_mpi = True
build_cc = 'cc'
build_fc = 'ftn -Mdclchk'
build_ld =  'ftn'
build_omp = '-mp'
build_flags = '-fast'
build_prof = '-g -pg -Mprof=func'
build_debug = '-g -Ktrap=fp -Mbounds -Mchkptr'
build_real8 = '-Mr8'

#launch = 'OMP_NUM_THREAD={nthread} aprun -d {nthread} n {nproc} {command}'
launch = 'aprun -n {nproc} {command}'
submit = 'qsub "{name}.sh"'
submit2 = 'qsub -W depend="afterok:{depend}" "{name}.sh"'

