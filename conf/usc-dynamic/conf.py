notes = """
USC Dynamic Compute Nodes

https://geosys.usc.edu/wiki/index.php/Specifications
https://geosys.usc.edu/wiki/index.php/MPI_on_dynamic
https://geosys.usc.edu/wiki/index.php/PBS
8 x 2 Dual Intel Xeon 3.2GHz
2GB


Note from John Yu:

The PBS submission process now includes a routing system that will help
prioritize jobs to the proper nodes based on resources required.  By default,
you should NOT request a particular queue.  The default queue will route you to
the proper node if you specify the resources needed. For example:

qsub -l nodes=1,mem=20gb yourscript.pbs

"""

login = 'dynamic.usc.edu'
hosts = login,
maxnodes = 28
maxcores = 2
maxram = 1800
fortran_serial = 'ifort',
fortran_mpi = 'mpif90',
_ = '-u', '-std95', '-warn', '-o'
fortran_flags = {
    'g': ('-CB', '-traceback', '-g') + _,
    't': ('-CB', '-traceback') + _,
    'p': ('-O', '-pg') + _,
    'O': ('-O3',) + _,
}

