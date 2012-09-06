"""
USC HPC Linux Cluster

.login:
source /usr/usc/globus/default/setup.csh
#source /usr/usc/mpich/default/setup.csh
source /usr/usc/mpich2/1.3.1..10/setup.csh
setenv F77 gfortran
setenv F90 gfortran
"""

python = '/home/rcf-11/gely/local/python/bin/python'
rate = 1.1e6
queue = 'default'
#mpout = 0

queue_opts = [
    ('default',  {'maxnodes': 256, 'maxcores': 8, 'maxram': 12288, 'maxtime': 1440}),
    ('default',  {'maxnodes': 256, 'maxcores': 4, 'maxram':  4096, 'maxtime': 1440}),
    ('largemem', {'maxnodes':   1, 'maxcores': 8, 'maxram': 65536, 'maxtime': 1440*14}),
    ('nbns',     {'maxnodes':  48, 'maxcores': 8, 'maxram': 12288, 'maxtime': 1440*14}),
]

launch = 'mpiexec -n {nproc} {command}'

