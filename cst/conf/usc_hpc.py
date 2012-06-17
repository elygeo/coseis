"""
USC HPC Linux Cluster

http://www.usc.edu/hpcc/

hpc-login2.usc.edu

.login:
source /usr/usc/globus/default/setup.csh
#source /usr/usc/mpich/default/setup.csh
source /usr/usc/mpich2/1.3.1..10/setup.csh
setenv F77 gfortran
setenv F90 gfortran
"""

rate = 1.1e6
queue = 'default'

queue_opts = [
    ('default',  {'maxnodes': 256, 'core_range': [8], 'maxram': 12*1024, 'maxtime': 1440}),
    ('default',  {'maxnodes': 256, 'core_range': [4], 'maxram':  4*1024, 'maxtime': 1440}),
    ('largemem', {'maxnodes':   1, 'core_range': [8], 'maxram': 64*1024, 'maxtime': 14*1440}),
    ('nbns',     {'maxnodes':  48, 'core_range': [8], 'maxram': 12*1024, 'maxtime': 14*1440}),
]

launch = {
    'exec': 'mpiexec -n {nproc} {command}',
    'submit': 'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

