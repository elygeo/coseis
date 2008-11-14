notes = """
SDSU CSRC Babieca cluster
http://www.csrc.sdsu.edu/csrc/
http://babieca.sdsu.edu/
interactive nodes:
  10 x 2 Intel Xeon 2.4GHz
  1GB
batch nodes:
  32 x 2 Intel Xeon 2.4GHz
  2GB (node8 has 1GB)
"""
login = 'altai.sdsu.edu ssh babieca.sdsu.edu'
hosts = [ 'master' ]
nodes = 32
cores = 2
ram = 1800
rate = 100
getarg = 'getarg-pgf.f90'
sfc = [ 'pgf90', ]
mfc = [ 'mpif90' ]
_ = [ '-Mdclchk', '-o' ]
g = [ '-g', '-Ktrap=fp', '-Mbounds' ] + _
p = [ '-fast', '-Mprof=func' ] + _
O = [ '-fast' ] + _

