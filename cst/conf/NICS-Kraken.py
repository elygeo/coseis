"""
NICS Kraken: Cray XT5
"""

# machine properties
python = '/lustre/scratch/gely/local/bin/python'
account = 'TG-MCA03S012'
maxnodes = 64 * 129
maxcores = 12
maxram = 16384
maxtime = 1440
rate = 1e6

# MPI
ppn_range = []
nthread = 1
launch = 'aprun -n {nproc} {command}'

# MPI + OpenMP
ppn_range = [1]
nthread = 12
launch = 'OMP_NUM_THREAD={nthread} aprun -d {nthread} -n {nproc} {command}\n'

