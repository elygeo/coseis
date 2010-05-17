notes = """
USC HPC - http://www.usc.edu/hpcc/

Add these to your .bashrc:
    source /usr/usc/mpich/default/setup.sh
    source /usr/usc/globus/default/setup.sh

pbsnodes -a | grep main | sort | uniq -c
alias showme='qstat -n | grep -E "Elap$|Queue|-----|$USER"'

I/O to temporary space:
    /scratch

Use /home instead of /auto
Do not add to the front of your path on HPC

WARNING: MPI-IO does not seem to work well on HPCC.  Also, it has an extermely
cumbersome setup where I/O must occur from /scratch, which only exists while
the job is running.  If you have any alternatives to HPCC, consider using them.

EPD version: rh3-x86
"""
login = 'hpc-login1.usc.edu'
hosts = 'hpc-login1', 'hpc-login2'
queue = 'largemem'; maxnodes =   1; maxcores = 8; maxram = 63000; maxtime = 336, 00
queue = 'nbns';     maxnodes =  48; maxcores = 8; maxram = 11000; maxtime = 336, 00
queue = 'default';  maxnodes = 256; maxcores = 4; maxram =  3500; maxtime = 24, 00
queue = 'default';  maxnodes = 256; maxcores = 8; maxram = 11000; maxtime = 24, 00
sord_ = dict( rate = 1.1e6 )
launch = {
    's-exec':  '%(bin)s',
    's-debug': 'gdb %(bin)s',
    'submit':  'qsub "%(name)s.sh"',
    'submit2': 'qsub -W depend="afterok:%(depend)s" "%(name)s.sh"',
}

