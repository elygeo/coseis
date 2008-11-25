notes = """
USC HPC

http://www.usc.edu/hpcc/
Add these to your .cshrc:
  source /usr/usc/pgi/default/setup.csh
  source /usr/usc/mpich/default/setup.csh
Add these to your .bashrc:
  source /usr/usc/pgi/default/setup.sh
  source /usr/usc/mpich/default/setup.sh
Run from disks located at HPC:
  /auto/scec-00
  /auto/rcf-104
alias showme='qstat -u $USER'
qbalance -h
showstart
qstat
pbsnodes -a | grep properties | sort | uniq -c
"""
login = 'hpc-login1.usc.edu'
hosts = [ 'hpc-login1', 'hpc-login2' ]
queue = 'largemem'; maxnodes = 5;   maxcores = 8; maxram = 63000; maxtime = 336, 00
queue = 'large';    maxnodes = 256; maxcores = 8; maxram = 11000; maxtime = 24, 00
queue = 'quick';    maxnodes = 4;   maxcores = 4; maxram = 3500;  maxtime = 1, 00
queue = 'main';     maxnodes = 378; maxcores = 4; maxram = 3500;  maxtime = None
queue = 'quick';    maxnodes = 4;   maxcores = 8; maxram = 11000; maxtime = 1, 00
queue = 'main';     maxnodes = 382; maxcores = 8; maxram = 11000; maxtime = None
queue = 'scec';     maxnodes = 100; maxcores = 2; maxram = 1500;  maxtime = 336, 00
rate = 1.1e6

