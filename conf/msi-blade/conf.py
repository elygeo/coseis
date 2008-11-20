notes = """
UMN/MSI Blade

http://www.msi.umn.edu/hardware/blade/
IBM Bladecenter Linux cluster
268 x 2 dual-core 2.6 GHz AMD Opteron
8 GB
/scratch1
/scratch2
ulimit -s unlimited
ulimit -n 4096
~/.modulerc
#%Module1.0
module unload pathmpi
module load intelmpi
"""
login = 'blade.msi.umn.edu'
hosts = [ 'blade287' ]
queue = 'devel'; maxnodes = 16;  maxtime = 1, 00
queue = 'bc';    maxnodes = 268; maxtime = 48, 00
maxcores = 4;
maxram = 7000
fortran_mpi = [ 'mpif90' ]

# Pathscale
fortran_serial = [ 'pathf95' ]
fortran_getarg = ''
_ = [ '-o' ]
fortran_flags = {
    'g': [ '-g' ] + _,
    't': [] + _,
    'p': [ '-O', '-p' ] + _,
    'O': [ '-i8', '-O3', '-OPT:Ofast', '-fno-math-errno' ] + _,
}

# Intel
fortran_serial = [ 'ifort' ]
fortran_getarg = ''
_ = [ '-u', '-std95', '-warn', '-o' ]
fortran_flags = {
    'g': [ '-CB', '-traceback', '-g' ] + _,
    't': [ '-CB', '-traceback' ] + _,
    'p': [ '-O', '-pg' ] + _,
    'O': [ '-ipo', '-O3', '-no-prec-div' ] + _,
}

