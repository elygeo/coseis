"""
SDSU CSRC Babieca Linux Cluster

http://www.csrc.sdsu.edu/csrc/
http://babieca.sdsu.edu/

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

queue = 'workq'
maxnodes = 40
core_range = [1, 2]
maxram = 2048
rate = 0.5e6

launch  = 'mpirun -machinefile $HOME/machinefile -np {nproc} {command}'
launch  = 'mpiexec -n {nproc} {command}'
submit  = 'qsub "{name}.sh"'
submit2 = 'qsub -W depend="afterok:{depend}" "{name}.sh"'

