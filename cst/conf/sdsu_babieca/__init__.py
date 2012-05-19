"""
SDSU CSRC Babieca cluster

http://www.csrc.sdsu.edu/csrc/
http://babieca.sdsu.edu/
interactive nodes:
    8 x 2 Intel Xeon 2.4GHz
    1GB
batch nodes:
    40 x 2 Intel Xeon 2.4GHz
    2GB
"""

login = 'babieca.sdsu.edu'
hostname = 'master'
queue = 'workq'
maxnodes = 40
maxcores = 2
maxram = 1800
rate = 0.5e6
launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_exec':  'mpirun -machinefile mf -np {nproc} {command}',
    'm_debug': 'mpirun -machinefile mf -np {nproc} -dbg=gdb {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

