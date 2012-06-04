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
machinefile:
node41:4
node42:4
node43:2
node44:2
node45:4
node46:2
node47:2
node48:2
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
    'm_exec':  'mpiexec -n {nproc} {command}',
    'm_iexec': 'mpirun -machinefile $HOME/machinefile -np {nproc} {command}',
    'm_debug': 'mpirun -machinefile $HOME/machinefile -np {nproc} -dbg=gdb {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

