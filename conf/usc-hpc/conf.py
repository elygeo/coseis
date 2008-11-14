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
"""
login = 'hpc-login1.usc.edu'
hosts = [ 'hpc-login1', 'hpc-login2' ]
nodes = 256
cores = 4
ram = 13500
rate = 500
timelimit = 24, 00
