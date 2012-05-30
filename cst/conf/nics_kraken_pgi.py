"""
NICS Kraken

Install under /lustre/scratch/
See install/install-python-kraken.sh for statically linked Python.
Home directories have a 2 GB quota.
CrayPAT is useful for profiling and collecting hardware performance data.

.bashrc
module load git vim yt
alias qme='qstat -u $USER'
alias qdev='qsub -I -A account_string -l size=12,walltime=2:00:00'

showq
showbf
showusage
"""

login = 'kraken-pwd.nics.utk.edu'
hostname = 'kraken-pwd[1234]'
maxram = 15000
maxcores = 12
maxnodes = 8256
maxtime = 24, 00
rate = 1e6
fortran_serial = 'ftn'
fortran_mpi = 'ftn'

fortran_flags = {
    'f': '-Mdclchk',
    'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
    't': '-Ktrap=fp -Mbounds',
    'p': '-pg -Mprof=func',
    'O': '-fast',
    '8': '-Mr8',
}

cvms_opts = dict(
    fortran_flags = {
        'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
        'O': '-fast',
    },
)

launch = {
    's_exec':  '{command}',
    's_debug': 'gdb {command}',
    'm_debug': 'totalview aprun -n {nproc} {command}',
    'm_exec':  'aprun -n {nproc} {command}',
    'script':  'aprun -n {nproc} {command}',
    'submit':  'qsub "{name}.sh"',
    'submit2': 'qsub -W depend="afterok:{depend}" "{name}.sh"',
}

script_header = """\
#!/bin/bash
#PBS -A {account}
#PBS -N {name}
#PBS -M {email}
#PBS -l size={totalcores}
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
"""

script_pre = """
lfs setstripe -c 1 .
[ {nstripe} -ge -1 -a -d hold ] && lfs setstripe -c {nstripe} hold
"""

