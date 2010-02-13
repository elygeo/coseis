notes = """
USC Dynamic Compute Nodes

EPD version: rh3-x86_64

https://geosys.usc.edu/wiki/index.php/Specifications
https://geosys.usc.edu/wiki/index.php/MPI_on_dynamic
8 x 2 Dual Intel Xeon 3.2GHz
2GB


Not from John Yu:

The PBS submission process now includes a routing system that will help
prioritize jobs to the proper nodes based on resources required.  By default,
you should NOT request a particular queue.  The default queue will route you to
the proper node if you specify the resources needed. For example:

qsub -l nodes=1,mem=20gb yourscript.pbs

Please see https://geosys.usc.edu/wiki/index.php/PBS for more details.
"""
login = 'dynamic.usc.edu'
hosts = login,
maxnodes = 12
maxcores = 4
maxram = 1800

