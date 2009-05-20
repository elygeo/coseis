notes = """
NICS Kraken

/lustre/scratch/$USER
module
showusage
qsub -l debugging
showbf

Home directories have a 2 GB quota.
CrayPAT (Cray Performance Analysis Tools) is useful for profiling and
collecting hardware performance data

account: TG-MCA03S012
"""
login = 'kraken-pwd.nics.utk.edu'
hosts = [ 'kraken-pwd3' ]
queue = 'longsmall';  minnodes = 0;    maxnodes = 32;   maxtime = 60, 00
queue = 'small';      minnodes = 0;    maxnodes = 64;   maxtime = 24, 00
queue = 'medium';     minnodes = 65;   maxnodes = 1024; maxtime = 24, 00
queue = 'large';      minnodes = 1025; maxnodes = 4096; maxtime = 24, 00
queue = 'capability'; minnodes = 4097; maxnodes = 8256; maxtime = 24, 00
queue = 'batch';      minnodes = 0;    maxnodes = 4096; maxtime = 24, 00

maxcores = 8
maxram = 15000 # 4416 nodes #PBS -l feature=2gbpercore
maxram =  7000 # 3840 nodes
rate = 1e6 # just a guess
mode = 'm'
fortran_serial = [ 'ftn' ]
fortran_mpi = [ 'ftn' ]
_ = [ '-Mdclchk', '-o' ]
fortran_flags = {
    'g': [ '-Ktrap=fp', '-Mbounds', '-Mchkptr', '-g' ] + _,
    't': [ '-Ktrap=fp', '-Mbounds' ] + _,
    'p': [ '-pg', '-Mprof=func' ] + _,
    'O': [ '-fast' ] + _,
}

