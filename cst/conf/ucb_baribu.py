"""
UCB Baribu cluster
"""

login = hostname = 'baribu.geo.berkeley.edu'
maxnodes = 7
maxcores = 8
maxram = 30000

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_debug': 'mpiexec -n {nproc} -gdb {command}',
    'm_exec':  'mpiexec -n {nproc} {command}',
    'script':  'mpirun -hostfile $PBS_NODEFILE {command}',
}

script_header = """\
#!/bin/bash -e
#PBS -N {name}
#PBS -M {email}
#PBS -l nodes={nodes}:ppn={ppn}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -V
#PBS -r n
export -n PBS_ENVIRONMENT
"""

