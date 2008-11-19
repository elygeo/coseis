notes = """
UMN/MSI Calhoun

http://www.msi.umn.edu/hardware/calhoun/
SGI Altix XE 1300 cluster
256 x 8 2.66 GHz Intel Xeon
16 GB
/scratch1
ulimit -s unlimited
ulimit -n 4096
vi ~/.modulerc
#%Module1.0
module load intel vmpi
"""
login = 'calhoun.msi.umn.edu'
hosts = [ 'login1' ]
maxnodes = 256
maxcores = 8
maxram = 15000
maxtime = 24, 00
sfc = [ 'ifort' ]
mfc = [ 'mpif90' ]
getarg = ''
_ = [ '-u', '-std95', '-warn', '-o' ]
g = [ '-CB', '-traceback', '-g' ] + _
t = [ '-CB', '-traceback' ] + _
p = [ '-O', '-pg' ] + _
O = [ '-O3' ] + _

