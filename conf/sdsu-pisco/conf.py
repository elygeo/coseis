notes = """
SDSU Pisco

ssh -fNL localhost:8022:pisco.sdsu.edu:22 sciences.sdsu.edu
ssh -p 8022 localhost

Use MPICH instead of OpenMPI:
export PATH="/opt/mpich2/gnu/bin:${PATH}"
"""
login = 'pisco.sdsu.edu'
hosts = 'pisco.sdsu.edu',
maxnodes = 1
maxcores = 8
maxram = 30000
fortran_serial = 'ifort',
fortran_serial = 'gfortran',
fortran_mpi = 'mpif90',
_ = '-fimplicit-none', '-Wall', '-o'
fortran_flags = {
    'g': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g') + _,
    't': ('-fbounds-check', '-ffpe-trap=invalid,zero,overflow') + _,
    'p': ('-O', '-pg') + _,
    'O': ('-O3',) + _,
}

