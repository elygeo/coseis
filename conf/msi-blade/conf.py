notes = """
UMN/MSI Blade

http://www.msi.umn.edu/hardware/blade/
IBM Bladecenter Linux cluster
268 x 2 dual-core 2.6 GHz AMD Opteron
8 GB
/scratch1
/scratch2
alias showme='qstat -u $USER'

.bashrc
ulimit -s unlimited
ulimit -n 4096

~/.modulerc
#%Module1.0
module load intelmpi
"""
login = 'blade.msi.umn.edu'
hosts = [ 'blade285', 'blade286', 'blade287', 'blade288' ]
queue = 'devel'; maxnodes = 16;  maxtime = 1, 00
queue = 'bc';    maxnodes = 268; maxtime = 48, 00
maxcores = 4;
maxram = 7000
fortran_mpi = [ 'mpif90' ]
fortran_serial = [ 'ifort' ]
_ = [ '-u', '-std95', '-warn', '-o' ]
fortran_flags = {
    'g': [ '-CB', '-traceback', '-g' ] + _,
    't': [ '-CB', '-traceback' ] + _,
    'p': [ '-O', '-pg' ] + _,
    'O': [ '-ipo', '-O3', '-no-prec-div' ] + _,
}

