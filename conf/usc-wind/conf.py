notes = """
USC Wind

Intel(R) Pentium(R) 4 CPU 3.20GHz
1GB
"""
login = 'wind.usc.edu'
hosts = [ login ]
maxnodes = 1
maxcores = 2
maxram = 800
rate = 1.0e6
fortran_serial = [ 'gfortran' ]
fortran_mpi = []
_ = [ '-fimplicit-none', '-Wall', '-o' ]
fortran_flags = {
    'g': [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g' ] + _,
    't': [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _,
    'p': [ '-O', '-pg' ] + _,
    'O': [ '-O3' ] + _,
}

