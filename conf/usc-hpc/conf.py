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
qbalance -h
showstart
qstat
pbsnodes -a | grep properties | sort | uniq -c
"""
login = 'hpc-login1.usc.edu'
hosts = [ 'hpc-login1', 'hpc-login2' ]
queue = 'quick'
queue = 'large'
queue = 'largemem'; maxnodes = 5;   maxcores = 8; maxram = 63000 # dualcore
queue = 'main';     maxnodes = 378; maxcores = 4; maxram = 3500  # dualcore
queue = 'main';     maxnodes = 382; maxcores = 8; maxram = 11000 # quadcore
queue = 'scec';     maxnodes = 100; maxcores = 2; maxram = 1500  # singlecore
maxtime = 24, 00
rate = 1.1e6

