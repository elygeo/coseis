"""
USC HPC - http://www.usc.edu/hpcc/

Add these to your .bashrc:
    source /usr/usc/openmpi/default/setup.sh
    source /usr/usc/globus/default/setup.sh
    export F77=gfortran
    export F90=gfortran

MPICH install is very old, so don't use:
    source /usr/usc/mpich/default/setup.sh

pbsnodes -a | grep main | sort | uniq -c
alias showme='qstat -n | grep -E "Elap$|Queue|-----|$USER"'

MPI-IO on output does not seem to work well, so use: mpout = 0

I/O to temporary space: /scratch
Do not add to the front of your path on HPC
Use /home instead of /auto
"""
login = 'hpc-login2.usc.edu'
hostname = 'hpc-login[12]'
queue = 'largemem'; maxnodes =   1; maxcores = 8; maxram = 63000; maxtime = 336, 00
queue = 'nbns';     maxnodes =  48; maxcores = 8; maxram = 11000; maxtime = 336, 00
queue = 'default';  maxnodes = 256; maxcores = 4; maxram =  3500; maxtime = 24, 00
queue = 'default';  maxnodes = 256; maxcores = 8; maxram = 11000; maxtime = 24, 00
rate = 1.1e6
launch = {
    's_exec':  '%(command)s',
    's_debug': 'gdb %(command)s',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -W depend="afterok:%(depend)s" "%(name)s.sh"',
}

