"""
SDSU Pisco

ssh -fNL localhost:8022:pisco.sdsu.edu:22 sciences.sdsu.edu
ssh -p 8022 localhost

Use MPICH instead of OpenMPI:
export PATH="/opt/mpich2/gnu/bin:${PATH}"
"""

login = hostname = 'pisco.sdsu.edu'
maxcores = 8
maxram = 32 * 1024
fortran_serial = 'gfortran'
fortran_mpi = 'mpif90'

