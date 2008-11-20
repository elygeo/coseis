notes = """
SDSC TeraGrid IA64 cluster

http://www.sdsc.edu/user_services/ia64/
http://clumon.sdsc.edu/
http://grid.ncsa.uiuc.edu/teragrid/status/
Interactive nodes
  tg-c127, tg-c128, tg-c129, tg-c130
  4 x 2 Intel Itanium 2 1.5GHz
  4GB (3GB usable)
Batch nodes:
  252 x 2 Intel Itanium 2 1.5GHz
  4GB (3GB usable)
Always run from a subdirectory of /gpfs/
vi ~/.soft
  @remove +intel-compilers
  @remove +intel-c-8.0.066-f-8.0.046-r1
  @remove +mpich-gm-intel
  +intel-c-9.0.032-f-9.0.033
  +mpich-gm-1.2.6-intel9032
  @teragrid
Useful commands:
  myprojects
  reslist
  showq
  show_bf
  show_bf-all
"""
login = 'tg-login2.sdsc.teragrid.org'
hosts = [ 'tg-login1', 'tg-login2' ]
queue = 'dque'
maxnodes = 256
maxcores = 2
maxram = 3000
maxtime = 18,00
rate = 2.2e6
sfc = [ 'ifort' ]
mfc = [ 'mpif90' ]
_ = [ '-u', '-std95', '-warn', '-o' ]
g = [ '-CB', '-traceback', '-g' ] + _
t = [ '-CB', '-traceback' ] + _
p = [ '-O', '-pg' ] + _
O = [ '-O3' ] + _
getarg = ''

