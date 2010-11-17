"""
USC Dynamic Compute Nodes

https://geosys.usc.edu/wiki/index.php/Specifications
https://geosys.usc.edu/wiki/index.php/MPI_on_dynamic
https://geosys.usc.edu/wiki/index.php/PBS
8 x 2 Dual Intel Xeon 3.2GHz
2GB

For interative nodes:
qsub -l nodes=1,walltime=24:00:00 -I -X

Note from John Yu:

The PBS submission process now includes a routing system that will help
prioritize jobs to the proper nodes based on resources required.  By default,
you should NOT request a particular queue.  The default queue will route you to
the proper node if you specify the resources needed. For example:

qsub -l nodes=1,mem=20gb yourscript.pbs

"""

login = hostname = 'dynamic.usc.edu'
maxnodes = 24
maxcores = 2
maxram = 1800
fortran_serial = 'gfortran'
fortran_mpi = 'mpif90'
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'm_exec':  'qsub -I "%(name)s.sh"',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -W depend="afterok:%(depend)s" "%(name)s.sh"',
}

